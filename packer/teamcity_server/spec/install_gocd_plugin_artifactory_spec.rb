control "install_gocd_plugin_artifactory-1.0" do
  impact 1.0
  title "install_gocd_plugin_artifactory"
  desc "install_gocd_plugin_artifactory spec"

  describe file( '/opt/gocd-plugins/' ) do
    it { should be_directory }
  end

  describe file( '/var/lib/go-server/' ) do
    it { should be_directory }
  end

  describe file( '/opt/gocd-plugins/go-generic-artifactory-poller.jar' ) do
    it { should exist }
  end
end
