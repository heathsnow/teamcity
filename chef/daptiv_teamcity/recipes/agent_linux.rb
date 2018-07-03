#
# Cookbook Name:: daptiv_teamcity
# Recipe:: agent_linux
#
# Copyright 2018 Changepoint
#
# TeamCity Linux build agent role
require 'time'

# Logic block to read data bag for user information
tc_userdata = data_bag_item('teamcity', 'buildagent_creds')

# Set the server_url for the default agent we're configuring
node.override['teamcity']['agents']['server_url'] =
  node['daptiv_teamcity']['server_url']

# Set the system directory for the default agent we're configuring
node.override['teamcity']['agents']['system_dir'] =
  node['daptiv_teamcity']['linux']['system_dir']

# Install TeamCity agent
include_recipe 'teamcity::agent_linux'

# Configure SSH for GitHub access by this agent
tc_local_user = tc_userdata['username']
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
  owner tc_local_user # Sets filesystem location for the .ssh dir
  action :create_if_missing
end

# Create nuget config
daptiv_nuget_config tc_local_user do
end

# Create gem config
daptiv_gem_config tc_local_user do
end

# Create npm config
npm_auth_token = data_bag_item('teamcity', 'npm_auth_token')
daptiv_nodejs_npm_config 'generate_teamcity_npmrc' do
  user tc_local_user
  auth npm_auth_token['auth_token']
  always_auth true
  email 'teamcity@daptiv.com'
end

include_recipe 'daptiv_docker'
# Configure docker
daptiv_docker_config 'teamcity' do
end
