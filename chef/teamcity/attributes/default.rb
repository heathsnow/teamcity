# Cookbook Name:: teamcity
# Attributes:: default
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

default['teamcity']['agents']['default'] = {}
default['teamcity']['agent_windows']['ntservice_user'] = nil
default['teamcity']['agent_windows']['ntservice_password'] = nil
default['teamcity']['agents']['server_url'] = nil
default['teamcity']['agents']['name'] =
  ENV['COMPUTERNAME'].to_s.empty? ? ENV['HOSTNAME'] : ENV['COMPUTERNAME']
default['teamcity']['agents']['user'] = 'teamcity'
default['teamcity']['agents']['group'] = 'teamcity'
default['teamcity']['agents']['home'] = nil
default['teamcity']['agents']['system_dir'] = '.'
default['teamcity']['agents']['logs_dir'] = 'logs'
default['teamcity']['agents']['work_dir'] = 'work'
default['teamcity']['agents']['temp_dir'] = 'tmp'
default['teamcity']['agents']['own_address'] = nil
default['teamcity']['agents']['own_port'] = 9090
default['teamcity']['agents']['authorization_token'] = nil
default['teamcity']['agents']['system_properties'] = {}
default['teamcity']['agents']['env_properties'] = {}
