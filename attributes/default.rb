default['cloudless-box']['firewall.rules'] = %w(http sshd)
default['cloudless-box']['applications.prefix'] = 'deploy'
default['cloudless-box']['applications'] = %w{vision foundation}
default['cloudless-box']['applications.vision.database'] = true