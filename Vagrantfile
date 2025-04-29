VM = {
  'controlplane' => {
    ip_public: '192.168.1.2',
    ip_private: '192.168.56.2',
  },
  'node1' => {
    ip_public: '192.168.1.3',
    ip_private: '192.168.56.3'
  },
  'nfs' => {
    ip_public: '192.168.1.4',
    ip_private: '192.168.56.4'
  }
}
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/jammy64"
  
  # NFS Server
  config.vm.define "nfs" do |nfs|
    nfs.vm.hostname = "nfs"
    
    # IP
    nfs.vm.network "public_network", ip: VM['nfs'][:ip_public], bridge: "enp42s0"
    #nfs.vm.network "private_network", ip: VM['nfs'][:ip_private]
    
    # Provision
    nfs.vm.provision "shell", path: "provision-nfs.sh"
    
    # Disk size
    nfs.disksize.size = '500GB'
  end

  # Controlplane
  config.vm.define "controlplane" do |controlplane|
    controlplane.vm.hostname = "controlplane"
    
    # IP
    controlplane.vm.network "public_network", ip: VM['controlplane'][:ip_public], bridge: "enp42s0"
    #controlplane.vm.network "private_network", ip: VM['controlplane'][:ip_private]
    
    # Volume
    controlplane.vm.synced_folder "/home/doko/k8s_cluster/volumes/controlplane", "/home/vagrant/volumes/"
    
    # Provision
    controlplane.vm.provision "shell", path: "provision-k8s.sh"
    controlplane.vm.provision "shell", path: "provision-controlplane.sh"

    # Disk size
    controlplane.disksize.size = '75GB'
  end

  # Node1
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"

    # IP
    node1.vm.network "public_network", ip: VM['node1'][:ip_public], bridge: "enp42s0"
    #node1.vm.network "private_network", ip: VM['node1'][:ip_private]
    
    # Volume
    node1.vm.synced_folder "/home/doko/k8s_cluster/volumes/node1", "/home/vagrant/volumes/"
    
    # Provision
    node1.vm.provision "shell", path: "provision-k8s.sh"
    node1.vm.provision "shell", inline: <<-SHELL
      sudo reboot
    SHELL

    # Disk size
    node1.disksize.size = '75GB'
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     # vb.gui = true
     # Customize the amount of memory on the VM:
     vb.memory = "4096"
     # Customize the number of cpu
     vb.cpus = 2
   end
  
  
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
   #config.vm.provision "shell", inline: <<-SHELL
   # sudo apt update
   #SHELL
end
