# rubocop:disable Metrics/BlockLength

describe 'daptiv_teamcity::agent_linux' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    end.converge(described_recipe)
  end

  it 'updates apt cache' do
    expect(chef_run).to update_apt_update('cache')
  end

  it 'should include teamcity::agent_linux recipe' do
    expect(chef_run).to include_recipe 'teamcity::agent_linux'
  end

  it 'should create daptiv_github_git_config' do
    expect(chef_run).to create_daptiv_github_git_config('teamcity_git_config')
  end

  it 'should create daptiv_github_sshkey if missing' do
    expect(chef_run).to create_daptiv_github_sshkey_if_missing(
      'teamcity_github_key'
    )
  end

  it 'creates nuget config' do
    expect(chef_run).to create_daptiv_nuget_config('teamcity')
  end

  it 'creates gem config' do
    expect(chef_run).to create_daptiv_gem_config('teamcity')
  end

  it 'generates daptiv_nodejs_npm_config' do
    expect(chef_run).to generate_daptiv_nodejs_npm_config(
      'generate_teamcity_npmrc'
    )
  end

  it 'configures docker' do
    expect(chef_run).to create_daptiv_docker_config 'teamcity'
  end

  it 'should create user with teamcity' do
    expect(chef_run).to create_user('teamcity')
  end
end
