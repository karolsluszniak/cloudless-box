Vagrant.configure(2) do |config|
  config.vm.box = "box-cutter/centos71"
  config.vm.network "private_network", ip: "192.168.33.133"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "cloudless-box"
    chef.json = { postgresql: { password: { postgres: 'postgres' } } }
  end

  # config.vm.provision :chef_client do |chef|
  #   chef.add_recipe "cloudless-box"
  #   chef.chef_server_url = "https://api.opscode.com/organizations/cloudless"
  #   chef.validation_key_path = "../../.chef/cloudless-validator.pem"
  #   chef.validation_client_name = "cloudless-validator"
  #   chef.node_name = "vagrant"
  #   chef.delete_node = true
  # end
end
