Vagrant.configure(2) do |config|
  config.vm.box = "box-cutter/centos71"
  config.vm.network "private_network", ip: "192.168.33.133"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "cloudless-box"
    chef.json = {
      'cloudless-box' => {
        'applications' => {
          'vision' => {
            'layout' => 'rails',
            'ruby' => '2.2.2',
            'postgresql' => true,
            'repository' => 'git@bitbucket.org:karolsluszniak/vision.git'
          },
          'videku' => {
            'layout' => 'node',
            'bower' => true,
            'repository' => 'git@bitbucket.org:karolsluszniak/videoreader.git',
            'env' => {
              'google_analytics_id' => 'UA-54811904-1'
            }
          },
          'leaderboard' => {
            'layout' => 'meteor',
            'mongodb' => true,
            'repository' => 'git@github.com:karolsluszniak/meteor-leaderboard.git'
          }
        },
        'backup' => {
          'bucket' => 'cloudless-ks3-backup',
          'access_key_id' => 'AKIAIPH2IZHKA7M6CQYA',
          'secret_access_key' => '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'
        },
        'firewall' => {
          'rules' => %w(http ssh)
        }
      }
    }
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
