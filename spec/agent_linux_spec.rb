describe 'teamcity::agent_linux' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'windows', version: '2008R2') do |node|
      node.set['teamcity']['agents']['default']['server_url'] = 'http://teamcity.example.com'
    end.converge(described_recipe)
  end

  it 'should create user with teamcity' do
    expect(chef_run).to create_user('teamcity')
  end

end
