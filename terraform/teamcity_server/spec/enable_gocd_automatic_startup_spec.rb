control "enable_gocd_automatic_startup" do
  impact 1.0
  title "enable_gocd_automatic_startup"
  desc "enable_gocd_automatic_startup spec"

  describe systemd_service('go-server') do
    it { should be_installed }
    it { should be_enabled }
  end
end
