control "install_gocd_plugin_s3-1.0" do
  impact 1.0
  title "install_gocd_plugin_s3"
  desc "install_gocd_plugin_s3 spec"

  describe file( '/opt/gocd-plugins/' ) do
    it { should be_directory }
  end

  describe file( '/var/lib/go-server/' ) do
    it { should be_directory }
  end

  describe file( '/opt/gocd-plugins/gocd-s3-poller-1.0.0.jar' ) do
    it { should exist }
  end
end
