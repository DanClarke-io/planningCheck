# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "ubuntu/trusty64"
	config.vm.box_version = "20151217.0.0"
	config.vm.hostname = "benchmark"
	config.vm.network :forwarded_port, host: 8080, guest: 80
	config.vm.network :forwarded_port, host: 3305, guest: 3306
	config.vm.network "private_network", ip: "192.168.33.10"
	# config.ssh.username = 'root'
	# config.ssh.password = 'vagrant'
	# config.ssh.insert_key = 'true'
	config.vm.provision :shell, path: "data/bootstrap.sh"
end
