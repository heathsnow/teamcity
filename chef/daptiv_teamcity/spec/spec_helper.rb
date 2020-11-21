require 'chefspec'
require 'chefspec/berkshelf'

# rubocop:disable Metrics/BlockLength

ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.platform = 'ubuntu'
  config.version = '16.04'
  ENV['USERNAME'] = 'foo'
  ENV['USER'] = 'foo'

  config.before(:each) do
    stub_data_bag_item('teamcity', 'buildagent_creds').and_return(
      username: 'teamcity',
      password: 'barword',
      domain_username: 'domain\user',
      domain_password: 'domain_pass',
      ssh_private_key: 'fookey',
      chef_ssh_private_key: 'barkey',
      github_username: 'foohub',
      github_email: 'barmail',
      github_token: 'fooward'
    )
    stub_data_bag_item('teamcity', 'npm_auth_token').and_return(
      auth_token: 'fake_auth_token'
    )
    stub_data_bag_item('docker', 'dockerhub').and_return(
      username: 'user',
      password: 'pass',
      email: 'user@email.com'
    )
    stub_data_bag_item('teamcity', 'npm_auth_token').and_return(
      auth_token: 'gobledeegook'
    )
    stub_command('getent group docker').and_return(true)
    stub_command('docker --help').and_return(true)
  end
end
