# Cookbook Name:: teamcity
# Recipe:: agent_windows
#
# Copyright 2018 Changepoing
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

# Prefer this cookbook's java_home if specified, otherwise try and use the Java cookbook's
java_home = node.deep_fetch('teamcity', 'java_home') || node.deep_fetch('java', 'java_home')
java_exe = 'java'
java_exe = ::File.join(java_home, 'bin', 'java.exe') if java_home

home = node['teamcity']['agents']['home'] || File.join('', 'home', node['teamcity']['agents']['user'])
system_dir = File.expand_path node['teamcity']['agents']['system_dir'], home
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

server_hash = Digest::MD5.hexdigest(server_url)
install_file = "#{Chef::Config[:file_cache_path]}/teamcity-agent-#{server_hash}.zip"
installed_check = Proc.new { ::File.exists? "#{system_dir}/bin" }

directory system_dir do
  recursive true
  action :create
end

remote_file install_file do
  source server_url + '/update/buildAgent.zip'
  action :create_if_missing
  not_if &installed_check
end

windows_zipfile system_dir do
  source install_file
  action :unzip
  not_if &installed_check
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

# Service configuration file
template "#{system_dir}/launcher/conf/wrapper.conf" do
  source 'wrapper.conf.erb'
  variables({ :name => agent_name,
    :java_exe => java_exe })
end

# Install as Windows service
execute "#{system_dir}/bin/service.install.bat" do
  cwd "#{system_dir}/bin"
  not_if { ::Win32::Service.exists?("TCBuildAgent_#{agent_name}") }
end

# SC commands windows_service is not yet available for this
ntservice_user = node['teamcity']['agent_windows']['ntservice_user']
ntservice_password = node['teamcity']['agent_windows']['ntservice_password']

# Stop the service
execute "#{system_dir}/bin/service.stop.bat" do
  cwd "#{system_dir}/bin"
  only_if { ::Win32::Service.status("TCBuildAgent_#{agent_name}").current_state == 'running' &&
    !ntservice_user.nil? }
end

# Configure ntservice creds for service
execute 'configure-service' do
  command "sc.exe config \"TCBuildAgent_#{agent_name}\" obj= \"#{ntservice_user}\" " \
    "password= \"#{ntservice_password}\" type= own"
  not_if { ntservice_user.nil? }
end


# Start the service
execute "#{system_dir}/bin/service.start.bat" do
  cwd "#{system_dir}/bin"
  only_if { ::Win32::Service.status("TCBuildAgent_#{agent_name}").current_state != 'running' }
end
