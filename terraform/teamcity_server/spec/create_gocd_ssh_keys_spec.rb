control "create_gocd_ssh_keys" do
  impact 1.0
  title "create_gocd_ssh_keys"
  desc "create_gocd_ssh_keys spec"

  gocd_ssh_profile_dir = '/var/go/.ssh/'

  describe file(File.join(gocd_ssh_profile_dir, 'id_rsa')) do
    it { should exist }
  end

  describe file(File.join(gocd_ssh_profile_dir, 'config')) do
    it { should exist }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00600' }
  end

  describe file(File.join(gocd_ssh_profile_dir, 'known_hosts')) do
    it { should exist }
    its('content') { should match(/.*\S.*/) }
  end
end
