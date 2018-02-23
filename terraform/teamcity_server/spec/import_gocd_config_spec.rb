control "import_gocd_config" do
  impact 1.0
  title "import_gocd_config"
  desc "import_gocd_config spec"

  gocd_config_file='/etc/go/cruise-config.xml'

  describe file(gocd_config_file) do
    it { should be_file }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00664' }
  end
end
