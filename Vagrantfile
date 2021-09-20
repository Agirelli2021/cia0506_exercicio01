# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/hirsute64"
  config.vm.hostname = "iaac-station"
  config.vm.provision "shell", path: "iaac.sh", run: "once"
  config.vm.network :private_network, ip: "10.0.0.10"
  config.vm.provider "virtualbox" do |v|
        v.cpus = 2
        v.memory = 4096
  end
end