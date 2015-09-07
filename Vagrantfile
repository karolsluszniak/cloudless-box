Vagrant.configure(2) do |config|
  config.vm.box = "box-cutter/centos71"
  config.vm.network "private_network", ip: "192.168.33.133"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "cloudless-box"
    chef.json = JSON.parse(File.read('.vagrant-chef-solo.json'))
  end
end
