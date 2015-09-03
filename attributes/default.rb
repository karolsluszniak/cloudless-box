default['cloudless-box']['firewall.rules'] = %w(http sshd)
default['cloudless-box']['applications.prefix'] = 'deploy'
default['cloudless-box']['applications'] = %w{vision foundation}
default['cloudless-box']['applications.vision.database'] = true
default['cloudless-box']['applications.vision.layout'] = 'rails'
default['cloudless-box']['applications.vision.ruby'] = '2.2.2'
default['cloudless-box']['applications.vision.repository'] =
  'git@bitbucket.org:karolsluszniak/vision.git'
default['cloudless-box']['applications.vision.url'] =
  'www.agarchia.pl'

