#
# Author:: Malte Swart (<chef@malteswart.de>)
# Cookbook Name:: teamcity
#
# Copyright 2013, Malte Swart
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

module Teamcity
  class Agent
    def initialize(name, node)
      @name = name
      @node = node

      # cache
    end

    # def cache
      # cache agent + shorter calls
      # @agent = @node['teamcity']['agents'][@name]
    # end

    # delegate to agent attributes hash of chef per default
    # def method_missing(meth, *args, &block)
      # if meth.is_a?(Symbol) && args.empty?
        # @agent[meth.to_s]
      # else
        # super
      # end
    # end

    # set default values for agent
    # def set_defaults
      # agent = @node.default_unless['teamcity']['agents'][@name]

      # agent['server_url'] = nil
      # agent['name'] = nil # generate name by teamcity

      # agent['user'] = 'teamcity'
      # agent['group'] = 'teamcity'

      # agent['home'] = nil

      # agent['system_dir'] = '.'
      # agent['work_dir'] = 'work'
      # agent['temp_dir'] = 'tmp'

      # agent['own_address'] = nil
      # agent['own_port'] = 9090
      # agent['authorization_token'] = nil

      # agent['system_properties'] = {}
      # agent['env_properties'] = {}

      # recache
      # cache
    # end

    def to_hash
      @agent.keys.inject({}) do |memento, key|
        memento[key] = self.send key.to_sym
        memento
      end
    end

    def agent_count()
      @node['teamcity']['agents'].to_hash.reject { |n, agent| agent.nil? }.size
    end

    def label(seperator)
      if agent_count() < 2
        ''
      else
        seperator + @name
      end
    end

    def server_url?
      @node['teamcity']['agents']['server_url'] && !@node['teamcity']['agents']['server_url'].empty?
    end

    def home
      @node['teamcity']['agents']['home'] || File.join('', 'home', @node['teamcity']['agents']['user'])
    end

    def system_dir
      File.expand_path @node['teamcity']['agents']['system_dir'], home
    end

    def work_dir
      File.expand_path @node['teamcity']['agents']['work_dir'], system_dir
    end

    def temp_dir
      File.expand_path @node['teamcity']['agents']['temp_dir'], system_dir
    end

    def name
      @node.default['teamcity']['agents']['name'] = ENV['COMPUTERNAME'] || ENV['HOSTNAME']
    end

    def authorization_token
      @node.default['teamcity']['agents']['authorization_token'] = nil
    end
  end
end
