#
# Cookbook Name:: daptiv_teamcity
# Recipe:: agent_windows
#
# Copyright 2018 Changepoint
#
# TeamCity Windows build agent role

# Logic block to read data bag for user information
require 'time'

tc_userdata = data_bag_item('teamcity', 'buildagent_creds')

# Set the server_url for the default agent we're configuring
node.override['teamcity']['agents']['server_url'] =
  node['daptiv_teamcity']['server_url']

# Set the system directory for the default agent we're configuring
node.override['teamcity']['agents']['system_dir'] =
  node['daptiv_teamcity']['system_dir']

# Set the service user using data bag tc_userdata
unless node.chef_environment == 'cookbook_ci'
  node.override['teamcity']['agent_windows']['ntservice_user'] =
    tc_userdata['domain_username']
  node.override['teamcity']['agent_windows']['ntservice_password'] =
    tc_userdata['domain_password']
end

# SSO cookbook for testagents use 9090 so need to update TC agent port to
# run on 9000 intead of the 9090 default
node.override['teamcity']['agents']['own_port'] = '9000'

include_recipe 'daptiv_java'
include_recipe 'teamcity::agent_windows'
include_recipe 'daptiv_github::install'

tc_local_user = tc_userdata['domain_username'][/\\(\w*)/, 1]
host_name = ENV['COMPUTERNAME'] || ENV['HOSTNAME']

daptiv_github_git_config "#{tc_local_user}_git_config" do
  user_email tc_userdata['github_email']
  user_name tc_userdata['github_username'] # Name of user for git operations
  owner tc_local_user # Sets filesystem location for the .gitconfig file
  action :create
end

# Create a new SSH key for GitHub
daptiv_github_sshkey "#{tc_local_user}_github_key" do
  email tc_userdata['github_email']
  password tc_userdata['github_password']
  key_passphrase ''
  key_title "#{tc_local_user}@#{host_name}.#{Time.now.utc.iso8601}"
  owner tc_local_user
  action :create_if_missing
end

# Create nuget config
daptiv_nuget_config tc_local_user do
end

# Install npm
include_recipe 'daptiv_ppm_build::npm_tools'

# Add npm directory to system PATH variable
windows_path 'C:\npm' do
  action :add
end

# Create npm config
npm_auth_token = data_bag_item('teamcity', 'npm_auth_token')
daptiv_nodejs_npm_config 'generate_teamcity_npmrc' do
  user tc_local_user
  auth npm_auth_token['auth_token']
  always_auth true
  email 'teamcity@daptiv.com'
end
