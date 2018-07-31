control "install_common_utilities-1.0" do
  impact 1.0
  title "install_common_utilities"
  desc "install_common_utilities spec"

  packages = %w(
    curl jq pry python-pip screen yarn
  )

  packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe pip('awscli') do
    it { should be_installed }
  end
end
