include_recipe 'iptables::default'

node['cloudless-box']['firewall.rules'].each do |rule|
  iptables_rule "#{rule}" do
    source "firewall/#{rule}.erb"
    action :enable
  end
end
