#
# Cookbook Name:: daptiv_teamcity
# Recipe:: default
#
# Copyright 2018 Changepoint
#
# TeamCity build agent role

user = ENV['USER'].to_s.empty? ? ENV['USERNAME'] : ENV['USER']
user = 'Administrator' if platform?('windows') \
  && node.chef_environment == 'cookbook_ci'

# set npmrc config for chef user so pkgs are installed to a globally
# accessible location during chef run
npm_auth_token = data_bag_item('teamcity', 'npm_auth_token')
daptiv_nodejs_npm_config 'generate_chef_user_npmrc' do
  user user
  auth npm_auth_token['auth_token']
  always_auth true
  email 'shawn.weitzel@changepoint.com'
end

if platform?('windows')
  include_recipe 'daptiv_teamcity::agent_windows'
else
  include_recipe 'daptiv_teamcity::agent_linux'
end
