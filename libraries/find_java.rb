require 'chef/mixin/shell_out'

module Teamcity
  class FindJava
    def self.find_java_exe(agent_bin_dir)
      find = Mixlib::ShellOut.new("#{agent_bin_dir}/findJava.bat")
      find.run_command
      Chef::Log.debug(find.stdout)
      /Java executable is found: '(.+)'/.match(find.stdout)[1]
    end
  end
end
