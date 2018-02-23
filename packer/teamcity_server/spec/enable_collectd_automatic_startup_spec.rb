control "enable_collectd_automatic_startup-1.0" do
  impact 1.0
  title "enable_collectd_automatic_startup"
  desc "enable_collectd_automatic_startup spec"

  describe service( 'collectd' ) do
    it { should be_enabled }
  end
end
