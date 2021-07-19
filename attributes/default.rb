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


#TAD4D cookbook execution status
default['tad4d']['status'] = 'failure'

case platform
when 'redhat'
  # attributes to set configuratioinn paratemeters in response.txt file required for TAD4D agent configuration
  default['tad4d']['ScanGroup'] = 'DEFAULT'
  default['tad4d']['MessageHandlerAddress'] = '10.0.0.1'
  default['tad4d']['Port'] = '9988'
  default['tad4d']['SecureAuthPort'] = '9999'
  default['tad4d']['ClientAuthSecurePort'] = '9977'
  default['tad4d']['CITInstallPath'] = '/opt/IBM/tad4d/CIT'
  default['tad4d']['SecurityLevel'] = '0'
  default['tad4d']['FipsEnabled'] = 'n'
  default['tad4d']['UseProxy'] = 'n'
  default['tad4d']['ProxyAddress'] = 'none'
  default['tad4d']['ProxyPort'] = '3128'
  default['tad4d']['InstallServerCertificate'] = 'n'
  default['tad4d']['ServerCustomSSLCertificate'] = 'n'
  default['tad4d']['ServerCertFilePath'] = ''
  default['tad4d']['AgentCertFilePath'] = ''
  default['tad4d']['export_cmd'] = 'export LMT_RESPONSE_FILE_PATH=/tmp/response_file.txt'
  default['tad4d']['bash_rc'] = '/root/.bashrc'
  default['tad4d']['AgentInstallPath'] = '/opt/IBM/tad4d/'
  # list of rpm packages required by TAD4D agent installation
  default['tad4d']['prereq_list'] = ['ksh', 'compat-libstdc++-33.x86_64', 'compat-libstdc++-33.i686']
  # TAD4D installer native file
  default['tad4d']['native_file'] = '7.5.0-TIV-ILMT-TAD4D-IF0026-agent-linux-x86.tar.gz'
  # rpm package of TAD4D agent to install
  default['tad4d']['package'] = 'ILMT-TAD4D-agent-7.5.0.126-linux-x86.rpm'
  # TAD4D uninstall script directory
  default['tad4d']['uninstall_script'] = '/opt/IBM/tlmunins.sh'
  # TAD4D agent installation directory
  default['tad4d']['install_path'] = '/opt/IBM'
  # TAD4D MessageHandlerAddress
  default['tad4d']['MessageHandlerAddress'] = '10.0.0.1'
  # url to download tad4d binaries
  # default['tad4d']['url'] = 'https://client.com/ibm/redhat7/tad4d/ILMT-TAD4D-agent-7.5.0.126-linux-x86.rpm'
  default['tad4d']['url'] = 'http://client.com/ibm/redhat7/tad4d/7.5.0-TIV-ILMT-TAD4D-IF0026-agent-linux-x86.tar.gz'
  # location for tlmagent script
  default['tad4d']['tlmagent_path'] = '/opt/IBM/tad4d'
  # tlmagent script
  default['tad4d']['tlmagent'] = '/opt/IBM/tad4d/tlmagent'
  default['tad4d']['volumegroup'] = 'ibmvg'
  default['tad4d']['logvols'] = [
  {
    'volname' => 'lv_tad4d',
    'size' => '500M',
    'mountpoint' => '/opt/IBM/tad4d',
    'fstype' => 'xfs',
  }
]
when 'windows'
  # attributes to set configuratioinn paratemeters in response.txt file required for TAD4D agent configuration
  default['tad4d']['ScanGroup'] = 'DEFAULT'
  default['tad4d']['MessageHandlerAddress'] = '10.0.0.1'
  default['tad4d']['Port'] = '9988'
  default['tad4d']['SecureAuthPort'] = '9999'
  default['tad4d']['ClientAuthSecurePort'] = '9977'
  default['tad4d']['CITInstallPath'] = 'C:\\PROGRA~1\\IBM\\tad4d\\CIT'
  default['tad4d']['SecurityLevel'] = '0'
  default['tad4d']['FipsEnabled'] = 'n'
  default['tad4d']['UseProxy'] = 'n'
  default['tad4d']['ProxyAddress'] = 'none'
  default['tad4d']['ProxyPort'] = '3128'
  default['tad4d']['InstallServerCertificate'] = 'n'
  default['tad4d']['ServerCustomSSLCertificate'] = 'n'
  default['tad4d']['ServerCertFilePath'] = ''
  default['tad4d']['AgentCertFilePath'] = ''
  default['tad4d']['AgentInstallPath'] = 'C:\\PROGRA~1\\IBM\\tad4d'
  # Remote location for TAD4D installer file
  default['tad4d']['tad4dfile_Path'] = 'https://client.com/ibm/windows2012R2/tad4d/7.5.0-TIV-ILMT-TAD4D-IF0026-agent-windows-x86.zip'
  # TSM installer file
  default['tad4d']['tad4dfile'] = '7.5.0-TIV-ILMT-TAD4D-IF0026-agent-windows-x86.zip'
  # Temp file where we copy the tad4d installer
  default['tad4d']['temp'] = 'C:\\tad4d_temp\\'
  # Installed file for tad4d agent
  default['tad4d']['alreadyInstalledFile'] = 'C:\\PROGRA~1\\IBM\\tad4d\\tlmagent.exe'
  # Path for tad4d installation
  default['tad4d']['install_path'] = 'C:\\PROGRA~1\\IBM\\tad4d'
  # Path for tad4d installation catche directory
  default['tad4d']['catche_path'] = 'C:\\Windows\\itlm-msi-cache'
when 'aix'
  # attributes to set configuratioinn paratemeters in response.txt file required for TAD4D agent configuration
  default['tad4d']['ScanGroup'] = 'DEFAULT'
  default['tad4d']['MessageHandlerAddress'] = '10.0.0.1'
  default['tad4d']['Port'] = '9988'
  default['tad4d']['SecureAuthPort'] = '9999'
  default['tad4d']['ClientAuthSecurePort'] = '9977'
  default['tad4d']['CITInstallPath'] = '/opt/IBM/tad4d/CIT'
  default['tad4d']['SecurityLevel'] = '0'
  default['tad4d']['FipsEnabled'] = 'n'
  default['tad4d']['UseProxy'] = 'n'
  default['tad4d']['ProxyAddress'] = 'none'
  default['tad4d']['ProxyPort'] = '3128'
  default['tad4d']['InstallServerCertificate'] = 'n'
  default['tad4d']['ServerCustomSSLCertificate'] = 'n'
  default['tad4d']['ServerCertFilePath'] = ''
  default['tad4d']['AgentCertFilePath'] = ''
  default['tad4d']['export_cmd'] = 'export LMT_RESPONSE_FILE_PATH=/tmp/response_file.txt'
  default['tad4d']['bash_rc'] = '/root/.bashrc'
  default['tad4d']['AgentInstallPath'] = '/opt/IBM/tad4d/'
  # TAD4D installer native file
  default['tad4d']['native_file'] = '7.5.0-TIV-ILMT-TAD4D-IF0023-agent-aix-ppc.tar'
  default['tad4d']['response_filename'] = 'response_file_AIX.txt'
  # rpm package of TAD4D agent to install
  default['tad4d']['package'] = 'ILMT-TAD4D-agent-7.5.0.126-linux-x86.rpm'
  # TAD4D uninstall script directory
  default['tad4d']['uninstall_script'] = '/opt/IBM/tlmunins.sh'
  # TAD4D agent installation directory
  default['tad4d']['install_path'] = '/opt/IBM'
  # TAD4D MessageHandlerAddress
  default['tad4d']['MessageHandlerAddress'] = '10.0.146.38'
  default['tad4d']['url'] = 'http://client.com/ibm/aix7/tad4d/7.5.0-TIV-ILMT-TAD4D-IF0023-agent-aix-ppc.tar'
  default['tad4d']['response_file_url'] = 'https://client.com/ibm/aix7/tad4d/response_file_AIX.txt'
  # location for tlmagent script
  default['tad4d']['tlmagent_path'] = '/opt/itlm/'
  # tlmagent script
  default['tad4d']['tlmagent'] = '/opt/IBM/tad4d/opt/itlm/tlmagent'
end