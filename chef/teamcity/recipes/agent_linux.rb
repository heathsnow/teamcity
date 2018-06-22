# Cookbook Name:: teamcity
# Recipe:: agent_linux
#
# Copyright 2018 Changepoint
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'digest/md5'

home = node['teamcity']['agents']['home'] || File.join('', 'home', node['teamcity']['agents']['user'])
system_dir = node['teamcity']['agents']['system_dir']
temp_dir = File.expand_path node['teamcity']['agents']['temp_dir'], system_dir
work_dir = File.expand_path node['teamcity']['agents']['work_dir'], system_dir
server_url = node['teamcity']['agents']['server_url']
agent_name = node['teamcity']['agents']['name']
agent_auth_token = node['teamcity']['agents']['authorization_token']

unless server_url && !server_url.empty?
  message = "You need to setup the server url for agent #{agent_name}"
  Chef::Log.fatal(message)
  raise message
end

# Create the teamcity group
group node['teamcity']['agents']['group'] do
end

# Create the teamcity user
user node['teamcity']['agents']['user'] do
  comment 'TeamCity Agent'
  gid node['teamcity']['agents']['group']
  home home
end

# Create the teamcity agent directory
directory system_dir do
  owner node['teamcity']['agents']['user']
  group node['teamcity']['agents']['group']
  recursive true
  action :create
end

server_hash = Digest::MD5.hexdigest(server_url)
install_file = "#{Chef::Config[:file_cache_path]}/teamcity-agent-#{server_hash}.zip"
installed_check = Proc.new { ::File.exists? "#{system_dir}/bin" }

remote_file install_file do
  source server_url + '/update/buildAgent.zip'
  mode 0555
  action :create_if_missing
  not_if &installed_check
end

package 'unzip' do
  action :install
  not_if &installed_check
end

# is there a better approach?
execute "unzip #{install_file} -d #{system_dir}" do
  user node['teamcity']['agents']['user']
  group node['teamcity']['agents']['group']
  creates "#{system_dir}/bin"
  not_if &installed_check
end

# as of TeamCity 6.5.4 the zip does NOT contain the file mode
%w{linux-x86-32 linux-x86-64 linux-ppc-64 }.each do |platform|
  file ::File.join(system_dir, 'launcher/bin/TeamCityAgentService-' + platform) do
    mode 0755
  end
end
%w{agent findJava install}.each do |script|
  file ::File.join(system_dir, 'bin', "#{script}.sh") do
    mode 0755
  end
end

# try to extract agent name + authenticationCode from file
agent_config = ::File.join system_dir, 'conf', 'buildAgent.properties'
if (agent_name.nil? || agent_auth_token.nil?) && ::File.readable?(agent_config)
  settings = File.new(agent_config).readlines.map do |s|
    s.index('#') ? s.slice(0, s.index('#')).strip : s.strip  # remove comments
  end.reject do |s|
    s.index('=').nil? # remove lines without =
  end.inject({}) do |memento, line| # split on = and convert to hash
    key, value = line.split '='
    memento[key] = value
    memento
  end
  if agent_name.nil? && !settings['name'].nil?
    Chef::Log.info "Setting agent (#{agent_name})'s name to #{settings['name']}"
    node.override['teamcity']['agents']['name'] = settings['name']
  end
  if agent_auth_token.nil? && !settings['authorizationToken'].nil?
    Chef::Log.info "Setting agent (#{agent_name})'s authorization_token"
    node.override['teamcity']['agents']['authorization_token'] = settings['authorizationToken']
  end
end

# buildAgent.properties (TeamCity will restart if this file is changed)
template agent_config do
  source 'buildAgent.properties.erb'
  user node['teamcity']['agents']['user']
  user node['teamcity']['agents']['group']
  mode 0644
  variables(
    server_url: server_url,
    name: node['teamcity']['agents']['name'],
    work_dir: work_dir,
    temp_dir: temp_dir,
    system_dir: system_dir,
    own_address: node['teamcity']['agents']['own_address'],
    own_port: node['teamcity']['agents']['own_port'],
    authorization_token: node['teamcity']['agents']['authorization_token'],
    system_properties: node['teamcity']['agents']['system_properties'],
    env_properties: node['teamcity']['agents']['env_properties']
  )
end

# create systemd service definition
service_name = 'teamcity-agent'
template "/lib/systemd/system/#{service_name}.service" do
  source 'teamcity-agent.service.erb'
  mode 0644
  variables(
    user: node['teamcity']['agents']['user'],
    system_dir: system_dir
  )
end

service service_name do
  action [:enable, :start]
  supports :status => true
end
