TAD4D Cookbook

The TAD4D cookbook verifies the prerequisites for TAD4D agent installation. On successful verification of the prerequisites it will perform silent installation of TAD4D agent version 7.5 on the node.It performs post-install configuration for the TAD4D agent. It defines the configuration files, locates and copy it on the required path on the node. 
This configuration file consists of input parameters required for TAD4D agent configuration during installation. and also it contains the recipe to uninstall the TAD4D agent

Requirements

- Storage : 2 GB
- RAM : 2 GB
- Versions
	- Chef Development Kit Version: 0.17.17
	- Chef-client version: 12.13.37
	- Kitchen version: 1.11.1
- RPM package required for TAD4D agent installation for Linux Platform
	- ksh
	- compat-libstdc++-33.x86_64 
	- compat-libstdc++-33.i686

Platforms

    RHEL-7/Winodws 2012

Chef

    Chef 11+

Cookbooks

    none

Resources/Providers

- tad4dagent
	This tad4dagent resource/provider performs the following :-
	For Linux platform:
	1. Check the prerequisites
	   - Verifies if the required rpm's are installed on the node. If not installed , it will install the rpm, in case of lower version of same rpm on the node already existing then
	     it will upgrade to latest version. No action in case of expected version is available on the node.   
	2. Creates necessary directories for 
	   - copying the TAD4D agent Native binary file
	   - copying the input file response.txt for agent configuration
	3. Extracting the TAD4D installer Native binary to fetch the required rpm file for installation
	4. Install the TAD4D rpm v7.5 from temporary directory
	5. Delete the temporary directory containing the files used during installation.

	For Winodws Platform:
    1. Creates necessary directories for 
	   - copying the TAD4D agent Native installer
	   - copying the input file response.txt for agent configuration
	2. Extracting the TAD4D installer to fetch the required setup file for installation
	3. Install the TAD4D v 7.5.0 from temporary directory
	4. Delete the temporary directory containing the files used during installation.
	5.uninstall the tad4d agent.
	
Example

1. tad4dagent 'Install-TAD4D-Agent' do
	action :install
end   

Actions

    :install - installs and configures the TAD4D agent


Recipes

    install_tad4d:: The recipe installs the required version of TAD4D agent for linux and windows platform. For linux, Performs prerequisite check and post-install configuration on successful validation of prereq.

2. tad4dagent 'unInstall-TAD4D-Agent' do
	action :uninstall
end   

Actions

    :uninstall - uninstall the TAD4D agent


Recipes

    uninstall_tad4d:: The recipe uninstalls the required version of TAD4D agent for linux and windows platform.

Attributes

The following attributes are set by default
# below attributes are the configuration input parameters defined in response file required for TAD4D installation
default['tad4d']['ScanGroup'] = 'DEFAULT'
default['tad4d']['MessageHandlerAddress'] = 'localhost'
default['tad4d']['Port'] = '9988'
default['tad4d']['SecureAuthPort'] = '9999'
default['tad4d']['ClientAuthSecurePort'] = '9977'
default['tad4d']['CITInstallPath'] = ''
default['tad4d']['SecurityLevel'] = '0'
default['tad4d']['FipsEnabled'] = 'n'
default['tad4d']['UseProxy'] = 'n'
default['tad4d']['ProxyAddress'] = 'none'
default['tad4d']['ProxyPort'] = '3128'
default['tad4d']['InstallServerCertificate'] = 'n'
default['tad4d']['ServerCustomSSLCertificate'] = 'n'
default['tad4d']['ServerCertFilePath'] = ''
default['tad4d']['AgentCertFilePath'] = ''

Below attributes are specific to linux platform:
default['tad4d']['prereq_list'] = ['ksh', 'compat-libstdc++-33.x86_64', 'compat-libstdc++-33.i686']	# list of rpm packages required by TAD4D agent installation
default['tad4d']['package'] = 'ILMT-TAD4D-agent-7.5.0.126-linux-x86.rpm'				# rpm package of TAD4D agent to install

Below attributes are specific to windows platform:
default['tad4d']['native_file'] = '7.5.0-TIV-ILMT-TAD4D-IF0026-agent-windows-x86.zip'    # TAD4D installer native file
default['tad4d']['temp'] = 'C:\\tad4d_temp\\'    # Temp file where we copy the tad4d installer
default['tad4d']['alreadyInstalledFile'] = 'C:\\Windows\itlm\\tlmagent.exe'     # Installed file for tad4d agent
default['tad4d']['install_path'] = 'C:\\Windows\\itlm'      # Path for tad4d installation
default['tad4d']['catche_path'] = 'C:\\Windows\\itlm-msi-catche'    # Path for tad4d installation catche directory

