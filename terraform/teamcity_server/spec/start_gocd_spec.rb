control "start_gocd" do
  impact 1.0
  title "start_gocd"
  desc "start_gocd spec"

  describe systemd_service('go-server') do
    it { should be_running }
  end
end
