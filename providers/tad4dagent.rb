########################################################################################################################
#                                                                                                                      #
#                                   TAD4D attribute for TAD4D Cookbook                                                 #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.07.2016                                                                                   #
#   Date Last Update    : 08.09.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

require 'chef/resource'

use_inline_resources

def whyrun_supported?
  true
end

action :install do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'redhat'
      check_prereq
    end
    install_tad4d
  end
end

# method to check the prerequisites for TAD4D agent
def check_prereq
  Chef::Log.info('Checking prerequisites for TAD4D agent')

  if platform?('redhat')
    node['tad4d']['prereq_list'].each do |dep|
      yum_package dep do
        action :install
        ignore_failure true
      end
    end
  end
end

# method to install the TAD4D agent
def install_tad4d
  case node['platform']
  when 'redhat'
   # Create /opt/IBM/tad4d dir to mount
  directory '/opt/IBM/tad4d' do
    recursive true
    action :create
  end    
  node['tad4d']['logvols'].each do |logvol|
    lvm_logical_volume logvol['volname'] do
    group   node['tad4d']['volumegroup']
    size    logvol['size']
    filesystem    logvol['fstype']
    mount_point   logvol['mountpoint']
    end
  end   
  if ::File.exist?(node['tad4d']['tlmagent'].to_s)

      # checking the tad4d agent version
      install_status = shell_out((node['tad4d']['tlmagent']).to_s + ' -v').stdout.chop

      # check if the tad4d agent is installed
      if install_status.to_s.include?('CODAG010I The command has been successfully executed')
        Chef::Log.error('TAD4d already installed ............Nothing to do !')
      end
    else
      # Create temp folder where we copy/create some files
      dir_list = ['/tmp/tad4d_temp', '/opt/IBM/tad4d/CIT']
      tempfolder = '/tmp/tad4d_temp'

      dir_list.each do |dir|
        directory dir do
          recursive true
          action :create
        end
      end

      # get TAD4D media to temp dir
      # ----------------------------------------------------------------
      media = tempfolder + '/' + node['tad4d']['native_file'].to_s

      remote_file media do
        source node['tad4d']['url'].to_s
        owner 'root'
        group 'root'
        mode '0755'
        action :create_if_missing
      end

      # Unpack media
      # ----------------------------------------------------------------

      Chef::Log.info('Extracting TAD4D binaries..........')
      execute 'unpack-media' do
        command 'cd ' + tempfolder.to_s + ' ; ' + ' tar -xf ' + media.to_s
        action :run
      end

      # Edit response file
      # ----------------------------------------------------------------
      Chef::Log.info('Editing the response_file with customized settings.........')
      template '/tmp/response_file.txt' do
        source 'response_file.txt.erb'
        variables(
          :ScanGroup => node['tad4d']['ScanGroup'],
          :MessageHandlerAddress => node['tad4d']['MessageHandlerAddress'],
          :Port => node['tad4d']['Port'],
          :SecureAuthPort => node['tad4d']['SecureAuthPort'],
          :ClientAuthSecurePort => node['tad4d']['ClientAuthSecurePort'],
          :CITInstallPath => node['tad4d']['CITInstallPath'],
          :SecurityLevel => node['tad4d']['SecurityLevel'],
          :FipsEnabled => node['tad4d']['FipsEnabled'],
          :UseProxy => node['tad4d']['UseProxy'],
          :ProxyAddress => node['tad4d']['ProxyAddress'],
          :ProxyPort => node['tad4d']['ProxyPort'],
          :InstallServerCertificate => node['tad4d']['InstallServerCertificate'],
          :ServerCustomSSLCertificate => node['tad4d']['ServerCustomSSLCertificate'],
          :ServerCertFilePath => node['tad4d']['ServerCertFilePath'],
          :AgentCertFilePath => node['tad4d']['AgentCertFilePath'],
          :AgentInstallPath => node['tad4d']['AgentInstallPath']
          )
        action :create
      end

      # install rpm package for TAD4D agent
      # ----------------------------------------------------------------
      pkg_path = tempfolder.to_s + '/' + node['tad4d']['package'].to_s

      bash 'install-tad4d-agent' do
        Chef::Log.debug('Installing TAD4D ...............Please wait')
        Chef::Log.debug('Setting response file path for customized configuration.........')
        code <<-EOH
        export LMT_RESPONSE_FILE_PATH=/tmp/response_file.txt
        rpm -Uvh #{pkg_path} --prefix #{node['tad4d']['AgentInstallPath']}
        EOH
        action :run
        not_if { shell_out('rpm -qa | grep TAD4D').stdout.chop != '' } # checking if tad4d is already installed
      end

      # change CIT log levels
      execute 'change-cit-log-level' do
        Chef::Log.debug('Changing CIT log level to MAX..........')
        command ' /opt/IBM/tad4d/CIT/bin/wscancfg -s trace_level MAX'
        action :run
      end

      # tad4d agent communicating with tad4d server
      execute 'communicate-with-server' do
        Chef::Log.debug('Communicating with TAD4D server..........')
        command "#{node['tad4d']['tlmagent_path']}/tlmagent -p"
        action :run
      end

      # tad4d agent software scan
      execute 'running-sw-scan' do
        Chef::Log.debug('Scheduling software scan..........')
        command "#{node['tad4d']['tlmagent_path']}/tlmagent -s"
        action :run
      end

      # deleting the temporary directory used for storing the TAD4D binaries
      directory tempfolder.to_s do
        Chef::Log.debug('Deleting the temporary directory /tmp/tad4d_temp.....................')
        recursive true
        action :delete
        only_if { ::File.exist?(tempfolder.to_s) }
      end

      # removing the response file from /tmp directory
      file '/tmp/response_file.txt' do
        Chef::Log.debug('Removing response_file from /tmp.........')
        action :delete
        only_if { ::File.exist?('/tmp/response_file.txt') }
      end
    end

  when 'windows'
    if ::File.exist?(node['tad4d']['alreadyInstalledFile'].to_s)
      Chef::Log.info('tad4d is already install, nothing to install for tad4d agent')
    else
      # Create temp directory where we copy/create source files to install tad4d agent
      directory node['tad4d']['temp'].to_s do
        action :create
      end
      # Edit response file
      # ----------------------------------------------------------------
      template "#{node['tad4d']['temp']}\\silent_agent.txt" do
        source 'response_file_win.txt.erb'
        variables(
          :ScanGroup => node['tad4d']['ScanGroup'],
          :MessageHandlerAddress => node['tad4d']['MessageHandlerAddress'],
          :Port => node['tad4d']['Port'],
          :TempPath => node['tad4d']['temp'],
          :SecureAuthPort => node['tad4d']['SecureAuthPort'],
          :ClientAuthSecurePort => node['tad4d']['ClientAuthSecurePort'],
          :CITInstallPath => node['tad4d']['CITInstallPath'],
          :SecurityLevel => node['tad4d']['SecurityLevel'],
          :FipsEnabled => node['tad4d']['FipsEnabled'],
          :UseProxy => node['tad4d']['UseProxy'],
          :ProxyAddress => node['tad4d']['ProxyAddress'],
          :ProxyPort => node['tad4d']['ProxyPort'],
          :InstallServerCertificate => node['tad4d']['InstallServerCertificate'],
          :ServerCustomSSLCertificate => node['tad4d']['ServerCustomSSLCertificate'],
          :ServerCertFilePath => node['tad4d']['ServerCertFilePath'],
          :AgentCertFilePath => node['tad4d']['AgentCertFilePath'],
          :AgentInstallPath => node['tad4d']['install_path']
          )
      end

      # get tad4d agent media to our temp dir
      remote_file node['tad4d']['tad4dfile_Path'].to_s do
        source node['tad4d']['tad4dfile_Path'].to_s
        path "#{node['tad4d']['temp']}#{node['tad4d']['tad4dfile']}"
        action :create
      end

      media = "#{node['tad4d']['temp']}#{node['tad4d']['tad4dfile']}"
      Chef::Log.info('media: media.to_s')
      # Unpack media
      ruby_block 'unzip-install-file' do
        block do
          Chef::Log.info('unziping the tad4d Installer file')
          cmd = powershell_out("cd #{node['tad4d']['temp']} ; tar -xvf #{media}")
          Chef::Log.info(cmd.stdout)
          action :create
        end
      end
      Chef::Log.info('Performing tad4d agent installation...')
      execute 'Install_tad4d' do
        command 'start /wait C:\\tad4d_temp\\setup.exe /z"/sfC:\\tad4d_temp\\silent_agent.txt" /L1033 /s /f2C:\\silent_setuptad4d_log.txt /VINSTALLDIR=C:\\PROGRA~1\\IBM\\tad4d'
        action :run
      end

      ruby_block 'wait-install' do
        block do
          sleep(500)
        end
        action :run
      end

       # tad4d agent communicating with tad4d server
       execute 'communicate-with-server' do
        Chef::Log.debug('Communicating with TAD4D server..........')
        command "#{node['tad4d']['install_path']}\\tlmagent -p"
        action :run
      end

      # tad4d agent software scan
      execute 'running-sw-scan' do
        Chef::Log.debug('Scheduling software scan..........')
        command "#{node['tad4d']['install_path']}\\tlmagent -s"
        action :run
      end
      
      # Deleting the Temp file
      directory node['tad4d']['temp'].to_s do
        recursive true
        action :delete
      end
    end
  when 'aix'

    if ::File.exist?(node['tad4d']['tlmagent'].to_s)

      # checking the tad4d agent version
      install_status = shell_out((node['tad4d']['tlmagent']).to_s + ' -v').stdout.chop

      # check if the tad4d agent is installed
      if install_status.to_s.include?('CODAG010I The command has been successfully executed')
        Chef::Log.error('TAD4d already installed ............Nothing to do !')
      end
    else
      # creating prerequisite FS
      # create volume group ibmvg as mandatory requirement
      execute 'create-VG-ibmvg' do
        command 'mkvg -f -y ibmvg hdisk1'
        action :run
        returns [0, 1]
        not_if { shell_out('lsvg | grep ibmvg').stdout.chop != '' }
      end
      # required FS
      volumes = [
        { lvname: 'lv_tad4d', fstype: 'jfs2', vgname: 'ibmvg', size: 500, fsname: '/opt/IBM/tad4d' }
      ]
      # Custom FS creation
      volumes.each do |data|
        ibm_tad4d_makefs "creation of #{data[:fsname]} file system" do
          lvname data[:lvname]
          fsname data[:fsname]
          vgname data[:vgname]
          fstype data[:fstype]
          size data[:size]
        end
      end
      # Create temp folder where we copy/create some files
      dir_list = ['/tmp/tad4d_temp', '/opt/IBM/tad4d/CIT']
      tempfolder = '/tmp/tad4d_software'

      directory tempfolder do
        recursive true
        action :create
      end

      # get TAD4D media to temp dir
      # ----------------------------------------------------------------
      media = tempfolder.to_s + '/' + node['tad4d']['native_file'].to_s
      response_file = tempfolder + '/' + node['tad4d']['response_filename'].to_s

      remote_file media.to_s do
        source node['tad4d']['url'].to_s
        owner 'root'
        mode '0755'
        action :create
      end

      # Unpack media
      # ----------------------------------------------------------------

      Chef::Log.info('Extracting TAD4D binaries..........')
      execute 'unpack-media' do
        command 'cd ' + tempfolder.to_s + ' ; ' + ' tar -xf ' + media.to_s
        action :run
      end

	  # Edit response file
      # ----------------------------------------------------------------
      Chef::Log.info('Editing the response_file with customized settings.........')
      template "#{response_file}" do
        source 'response_file.txt.erb'
        variables(
          :ScanGroup => node['tad4d']['ScanGroup'],
          :MessageHandlerAddress => node['tad4d']['MessageHandlerAddress'],
          :Port => node['tad4d']['Port'],
          :SecureAuthPort => node['tad4d']['SecureAuthPort'],
          :ClientAuthSecurePort => node['tad4d']['ClientAuthSecurePort'],
          :CITInstallPath => node['tad4d']['CITInstallPath'],
          :SecurityLevel => node['tad4d']['SecurityLevel'],
          :FipsEnabled => node['tad4d']['FipsEnabled'],
          :UseProxy => node['tad4d']['UseProxy'],
          :ProxyAddress => node['tad4d']['ProxyAddress'],
          :ProxyPort => node['tad4d']['ProxyPort'],
          :InstallServerCertificate => node['tad4d']['InstallServerCertificate'],
          :ServerCustomSSLCertificate => node['tad4d']['ServerCustomSSLCertificate'],
          :ServerCertFilePath => node['tad4d']['ServerCertFilePath'],
          :AgentCertFilePath => node['tad4d']['AgentCertFilePath'],
          :AgentInstallPath => node['tad4d']['AgentInstallPath']
          )
        action :create
      end

      # install rpm package for TAD4D agent
      # ----------------------------------------------------------------
      pkg_path = tempfolder.to_s + '/' + node['tad4d']['package'].to_s

      bash 'install-tad4d-agent' do
        Chef::Log.debug('Installing TAD4D ...............Please wait')
        Chef::Log.debug('Setting response file path for customized configuration.........')
        code <<-EOH
        export LMT_RESPONSE_FILE_PATH=#{response_file}
        installp -acgXd #{tempfolder}/ILMT-TAD4D-agent-7.5.0.123-aix-ppc ILMT-TAD4D-agent
        EOH
        action :run
        not_if { shell_out('lslpp -L | grep TAD4D').stdout.chop != '' } # checking if tad4d is already installed
      end

      # change CIT log levels
      bash 'change-cit-log-level' do
        code <<-EOH
        cd /opt/tivoli/cit/bin
        ./wscancfg -s trace_level MAX
        EOH
        action :run
      end

      # tad4d agent communicating with tad4d server
      bash 'communicate-server' do
        code <<-EOH
        cd #{node['tad4d']['tlmagent_path']}
        ./tlmagent -p
        EOH
        action :run
      end

      # tad4d agent software scan
      bash 'run-software-scan' do
        code <<-EOH
        cd #{node['tad4d']['tlmagent_path']}
        ./tlmagent -s
        EOH
        action :run
      end

      # deleting the temporary directory used for storing the TAD4D binaries
      directory tempfolder.to_s do
        Chef::Log.debug('Deleting the temporary directory /tmp/tad4d_software .....................')
        recursive true
        action :delete
      end

      # removing the response file from /tmp directory
      file response_file do
        Chef::Log.info('Removing response_file from /tmp.........')
        action :delete
        only_if { ::File.exist?(response_file) }
      end
    end
  end
end

action :uninstall do
  converge_by("Create #{@new_resource}") do
    uninstall_tad4d
  end
end

# Method to uninstall tad4d agent
def uninstall_tad4d
  case node['platform']
  when 'windows'
    if ::File.exist?(node['tad4d']['alreadyInstalledFile'].to_s)
      Chef::Log.info('Uninstalling the tad4d agent')
      execute 'Uninstall_tad4d' do
        cwd node['tad4d']['install_path'].to_s
        command 'tlmunins.bat'
        action :run
      end
      directory node['tad4d']['install_path'].to_s do
        recursive true
        action :delete
        only_if { ::File.directory?((node['tad4d']['install_path']).to_s) }
      end
      directory node['tad4d']['catche_path'].to_s do
        recursive true
        action :delete
        only_if { ::File.directory?((node['tad4d']['catche_path']).to_s) }
      end
    else
      Chef::Log.info('tad4d is not installed, nothing to uninstall for tad4d agent')
    end
  else
    Chef::Log.info('Uninstalling TAD4D agent .....')

    # uninstalling TAD4D agent using utilty script

    execute 'uninstall-tad4d' do
      command "#{node['tad4d']['AgentInstallPath']}tlmunins.sh"
      action :run
      only_if { shell_out('rpm -qa | grep TAD4D').stdout.chop != '' } # checking if tad4d is installed
    end

    tempfolder = '/tmp/tad4d_temp'
    # deleting the temporary directory used for storing the TAD4D binaries
    directory tempfolder.to_s do
      Chef::Log.debug('Deleting the temporary directory /tmp/tad4d_temp.....................')
      recursive true
      action :delete
      only_if { ::File.exist?(tempfolder.to_s) }
    end

    # removing the response file from /tmp directory
    file '/tmp/response_file.txt' do
      Chef::Log.debug('Removing response_file from /tmp.........')
      action :delete
      only_if { ::File.exist?('/tmp/response_file.txt') }
    end
  end
end