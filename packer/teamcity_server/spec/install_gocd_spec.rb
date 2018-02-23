control "install_gocd-1.0" do
  impact 1.0
  title "install_gocd"
  desc "install_gocd spec"

  describe service( 'go-server' ) do
    it { should_not be_enabled }
  end

  describe package( 'ldap-utils' ) do
    it { should be_installed }
  end

  describe package( 'nginx' ) do
    it { should be_installed }
  end

  describe package( 'openjdk-8-jre' ) do
    it { should be_installed }
  end
end
