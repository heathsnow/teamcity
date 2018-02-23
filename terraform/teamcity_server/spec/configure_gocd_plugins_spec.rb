control "configure_gocd_plugins" do
  impact 1.0
  title "configure_gocd_plugins"
  desc "configure_gocd_plugins spec"

  gocd_custom_plugins_dir = '/opt/gocd-plugins/'
  gocd_data_dir = '/var/lib/go-server/'
  gocd_plugins_dir = File.join(gocd_data_dir, 'plugins')
  gocd_external_plugins_dir = File.join(gocd_plugins_dir, 'external')

  describe file(gocd_data_dir) do
    it { should be_directory }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00750' }
  end

  describe file(gocd_plugins_dir) do
    it { should be_directory }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00775' }
  end

  describe file(gocd_external_plugins_dir) do
    it { should be_directory }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00775' }
  end

  # does not work, i think because the Dir.glob line does not
  # run with --sudo unlike things in the describe block
  Dir.glob("#{gocd_custom_plugins_dir}/*.jar") do |fname|
    describe file("#{gocd_custom_plugins_dir}#{fname}") do
      it { should exist }
    end
  end

  # does not work, i think because the Dir.glob line does not
  # run with --sudo unlike things in the describe block
  Dir.glob("#{gocd_external_plugins_dir}/*.jar") do |fname|
    describe file("#{gocd_external_plugins_dir}/#{fname}") do
      it { should be_symlink }
    end
  end
end
