
# check if the directory exist for tad4d installer zipfile
describe file('C:\\tad4d_temp') do
  it { should exist }
  its('type') { should eq :directory }
  it { should be_directory }
end

# check if silent_agent  file exist in temp directory
describe file('C:\\tad4d_temp\\silent_agent.txt') do
  it { should exist }
  its('type') { should eq file }
  its('mode') { should eq 0600 }
end

# check if the package tad4d Agent package is installed
describe package('') do
  it { should be_installed }
  its('version') { should eq 9.2 }
end

# check if tad4d service is running and enabled
describe service('besclient') do
  it { should be_enabled }
  it { should be_running }
end
