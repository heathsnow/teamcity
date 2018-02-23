control "create_gocd_local_admin" do
  impact 1.0
  title "create_gocd_local_admin"
  desc "create_gocd_local_admin spec"

  gocd_htpasswd_file='/etc/go/.htpasswd'

  describe file(gocd_htpasswd_file) do
    it { should be_file }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00664' }
    its('content') { should match /gocd-admin/ }
    its('content') { should match /gocd-read/ }
  end
end
