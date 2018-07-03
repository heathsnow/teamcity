module Win32
  class Service
    def self.exists?(_file)
      false
    end

    def self.status(_svc)
      ServiceStub.new
    end
  end
end

class ServiceStub
  @stubbed_state = 'stopped'

  def current_state
    @stubbed_state
  end
end

# rubocop:disable Metrics/BlockLength

describe 'daptiv_teamcity::agent_windows' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
      node.override['daptiv_teamcity']['server_url'] =
        'http://teamcity.daptiv.com'
      node.override['daptiv_teamcity']['system_dir'] = 'd:\\teamcity\\'
    end.converge(described_recipe)
  end

  it 'should include teamcity::agent_windows recipe' do
    expect(chef_run).to include_recipe('teamcity::agent_windows')
  end

  it 'should configure github' do
    expect(chef_run).to create_daptiv_github_git_config('user_git_config')
  end

  it 'should create daptiv_github_sshkey if missing' do
    expect(chef_run).to create_daptiv_github_sshkey_if_missing(
      'user_github_key'
    )
  end

  it 'should override ntservice_user' do
    ntservice_user = \
      chef_run.node['teamcity']['agent_windows']['ntservice_user']
    expect(ntservice_user).to eq('domain\user')
  end

  it 'should override ntservice_password' do
    ntservice_password = \
      chef_run.node['teamcity']['agent_windows']['ntservice_password']
    expect(ntservice_password).to eq('domain_pass')
  end

  it 'should override system_dir' do
    system_dir = chef_run.node['teamcity']['agents']['system_dir']
    expect(system_dir).to eq('d:\\teamcity\\')
  end

  it 'creates nuget config' do
    expect(chef_run).to create_daptiv_nuget_config 'user'
  end

  it 'should include daptiv_ppm_build::npm_tools recipe' do
    expect(chef_run).to include_recipe 'daptiv_ppm_build::npm_tools'
  end
end
