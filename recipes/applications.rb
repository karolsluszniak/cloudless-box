group node['cloudless-box']['application_group']

node['cloudless-box']['applications'].each do |app|
  user node['cloudless-box']['application_account_template'].gsub("%{app}", app) do
    group node['cloudless-box']['application_group']
  end
end
