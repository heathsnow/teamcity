# rubocop:disable Metrics/BlockLength

describe 'daptiv_teamcity::agent_linux' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    end.converge(described_recipe)
  end

  it 'should include daptiv_java cookbook' do
    expect(chef_run).to include_recipe('daptiv_java')
  end

  it 'teamcity::agent_linux is included' do
    expect(chef_run).to include_recipe 'teamcity::agent_linux'
  end

  it 'should include daptiv_github::install recipe' do
    expect(chef_run).to include_recipe('daptiv_github::install')
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

  it 'should install openjdk-7-jdk and openjdk-7-jre-headless' do
    expect(chef_run).to install_package('openjdk-7-jdk, openjdk-7-jre-headless')
  end
end
