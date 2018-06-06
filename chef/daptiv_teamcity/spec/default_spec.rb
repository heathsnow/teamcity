describe 'daptiv_teamcity::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic_attrs['hostname'] = 'teamcityagent'
    end.converge(described_recipe)
  end

  it 'should include ubuntu recipe' do
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

  it 'should include daptiv_ppm_build::npm_tools recipe' do
    expect(chef_run).to include_recipe 'daptiv_ppm_build::npm_tools'
  end
end
