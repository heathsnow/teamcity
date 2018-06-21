describe 'daptiv_teamcity::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic_attrs['hostname'] = 'teamcityagent'
    end.converge(described_recipe)
  end

  it 'should include daptiv_github::install recipe' do
    expect(chef_run).to include_recipe('daptiv_github::install')
  end

  it 'should include daptiv_java::default recipe' do
    expect(chef_run).to include_recipe('daptiv_java')
  end

  it 'should install openjdk-7-jdk and openjdk-7-jre-headless' do
    expect(chef_run).to install_package('openjdk-7-jdk, openjdk-7-jre-headless')
  end

  it 'should include daptiv_teamcity::agent_linux recipe' do
    expect(chef_run).to include_recipe 'daptiv_teamcity::agent_linux'
  end

  it 'should override agent name' do
    agent_name = chef_run.node['hostname']
    expect(agent_name).to eq('teamcityagent')
  end

  it 'should generate nodejs npm config' do
    expect(chef_run).to generate_daptiv_nodejs_npm_config(
      'generate_chef_user_npmrc'
    )
  end
end
