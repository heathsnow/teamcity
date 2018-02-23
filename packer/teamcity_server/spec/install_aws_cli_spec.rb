control "install_aws_cli-1.0" do
  impact 1.0
  title "install_aws_cli"
  desc "install_aws_cli spec"

  describe package( 'jq' ) do
    it { should be_installed }
  end

  describe package( 'python-pip' ) do
    it { should be_installed }
  end

  describe pip( 'awscli' ) do
    it { should be_installed }
  end
end
