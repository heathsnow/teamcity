require 'chef/mixin/shell_out'
require 'json'
require 'restclient'

# Test class for daptiv_buildagent_linux
class TestDaptivBuildagentLinux < MiniTest::Chef::TestCase
  describe 'daptiv_teamcity::agent_linux tests' do
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources
    include Chef::Mixin::ShellOut

    describe 'teamcity user creation' do
      it 'should have created a teamcity user' do
        teamcity_user_check =
          Mixlib::ShellOut.new('getent passwd teamcity')
        teamcity_user_check.run_command
        assert(
          teamcity_user_check.stdout.include?('teamcity'),
          'teamcity user exists'
        )
      end

      it 'should have created the id_rsa file for teamcity user' do
        assert ::File.exist? '/home/teamcity/.ssh/id_rsa'
      end
    end

    describe 'unzip package' do
      it 'should have been added' do
        assert package('unzip').must_be_installed
      end
    end
  end
end
