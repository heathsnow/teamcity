describe 'teamcity::agent_linux' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.override['teamcity']['agents']['server_url'] = 'http://teamcity.example.com'
    end.converge(described_recipe)
  end

  it 'should create user with teamcity' do
    expect(chef_run).to create_user('teamcity')
  end

end
