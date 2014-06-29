Vagrant.configure("2") do |config|
  config.butcher.verify_ssl = false
  #config.vm.box_url = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.2.0.box'
  #config.vm.box = 'opscode_ubuntu-12.04_chef-11.2.0'
  config.vm.box = 'vbox_windows-2008r2_chef-11.12.2'
  config.vm.guest = 'windows'
  config.vm.network :forwarded_port, guest: 5985, host: 5985, auto_correct: true
  config.vm.provider :virtualbox do |v, override|
    v.gui = true
  end
  config.vm.provision :chef_client do |chef|
    #chef.log_level = 'debug'
    #chef.verbose_logging = true
    chef.node_name = "vagrant-#{ENV['LOGNAME']}-teamcity.hq.daptiv.com"
    chef.add_recipe "daptiv_java"
    chef.add_recipe "teamcity"
    chef.json = {
      "teamcity" => {
        "agents" => {
          "default" => {
            "server_url" => "http://teamcity.hq.daptiv.com"
          }
        }
      }
    }
  end
end
