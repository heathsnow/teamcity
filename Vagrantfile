Vagrant.configure("2") do |config|
  config.vm.define 'ubuntu', primary: true do |ubuntu|
    ubuntu.vm.box_url = 'http://vagrantboxes.hq.daptiv.com/vagrant/boxes/virtualbox_ubuntu-12.04_chef-11.12.4_1.0.5.box'
    ubuntu.vm.box = 'virtualbox_ubuntu-12.04_chef-11.12.4_1.0.5'
    ubuntu.vm.provision :chef_client do |chef|
      chef.node_name = "vagrant-#{ENV['LOGNAME']}-teamcity-ubuntu.hq.daptiv.com"
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
  config.vm.define 'windows' do |windows|
    windows.vm.box_url = 'http://vagrantboxes.hq.daptiv.com/vagrant/boxes/vbox_windows-2008r2_chef-11.12.4.box'
    windows.vm.box = 'vbox_windows-2008r2_chef-11.12.4'
    windows.vm.communicator = :winrm
    windows.vm.provision :chef_client do |chef|
      chef.node_name = "vagrant-#{ENV['LOGNAME']}-teamcity-windows.hq.daptiv.com"
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
end
