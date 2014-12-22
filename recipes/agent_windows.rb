# Cookbook Name:: teamcity
# Recipe:: agent_windows
#
# Copyright 2014, Shawn Neal (sneal@sneal.net)
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

include_recipe 'chef-sugar::default'
require 'digest/md5'

# Prefer this cookbook's java_home if specified, otherwise try and use the Java cookbook's
java_home = node.deep_fetch('teamcity', 'java_home') || node.deep_fetch('java', 'java_home')
java_exe = 'java'
java_exe = ::File.join(java_home, 'bin', 'java.exe') if java_home

node.teamcity.agents.each do |name, agent| # multiple agents
  next if agent.nil? # support removing of agents

  agent = Teamcity::Agent.new name, node
  agent.set_defaults

  unless agent.server_url?
    message = "You need to setup the server url for agent #{name}"
    Chef::Log.fatal message
    raise message
  end

  server_hash = Digest::MD5.hexdigest(agent.server_url)
  install_file = "#{Chef::Config[:file_cache_path]}/teamcity-agent-#{server_hash}.zip"
  installed_check = Proc.new { ::File.exists? "#{agent.system_dir}/bin" }

  directory agent.system_dir do
    recursive true
    action :create
  end

  remote_file install_file do
    source agent.server_url + '/update/buildAgent.zip'
    action :create_if_missing
    not_if &installed_check
  end

  windows_zipfile agent.system_dir do
    source install_file
    action :unzip
    not_if &installed_check
  end

  # try to extract agent name + authenticationCode from file
  agent_config = ::File.join agent.system_dir, 'conf', 'buildAgent.properties'
  if (agent.name.nil? || agent.authorization_token.nil?) && ::File.readable?(agent_config)
    settings = File.new(agent_config).readlines.map do |s|
      s.index('#') ? s.slice(0, s.index('#')).strip : s.strip  # remove comments
    end.reject do |s|
      s.index('=').nil? # remove lines without =
    end.inject({}) do |memento, line| # split on = and convert to hash
      key, value = line.split '='
      memento[key] = value
      memento
    end
    if agent.name.nil? && !settings['name'].nil?
      Chef::Log.info "Setting agent (#{name})'s name to #{settings['name']}"
      agent.name = settings['name']
    end
    if agent.authorization_token.nil? && !settings['authorizationToken'].nil?
      Chef::Log.info "Setting agent (#{name})'s authorization_token"
      agent.authorization_token = settings['authorizationToken']
    end
  end

  # buildAgent.properties (TeamCity will restart if this file is changed)
  template agent_config do
    source 'buildAgent.properties.erb'
    variables agent.to_hash
  end

  # Service configuration file
  template "#{agent.system_dir}/launcher/conf/wrapper.conf" do
    source 'wrapper.conf.erb'
    variables({ :name => name, :java_exe => java_exe })
  end

  # Install as Windows service
  execute "#{agent.system_dir}/bin/service.install.bat" do
    cwd "#{agent.system_dir}/bin"
    not_if { ::Win32::Service.exists?("TCBuildAgent_#{name}") }
  end

  # Start the service
  execute "#{agent.system_dir}/bin/service.start.bat" do
    cwd "#{agent.system_dir}/bin"
    only_if { ::Win32::Service.status("TCBuildAgent_#{name}").current_state != 'running' }
  end

end
