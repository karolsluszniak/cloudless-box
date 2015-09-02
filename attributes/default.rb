default['cloudless-box']['firewall_rules'] = %w(http sshd)
default['cloudless-box']['application_group'] = 'deploy'
default['cloudless-box']['application_account_template'] = 'deploy_%{app}'
default['cloudless-box']['applications'] = %w{vision foundation}
