json_file = '.vagrant-chef-solo.json'

Vagrant.configure(2) do |config|
  config.vm.box = "box-cutter/centos71"
  config.vm.network "private_network", ip: "192.168.33.133"
  config.vm.provider("virtualbox") { |vb| vb.memory = "1024" }

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "cloudless-box"
    chef.json = JSON.parse(File.read(json_file)) if File.exists?(json_file)
  end
end
