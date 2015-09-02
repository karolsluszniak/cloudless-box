include_recipe 'iptables::default'

node['cloudless-box']['firewall_rules'].each do |rule|
  iptables_rule "firewall_#{rule}" do
    action :enable
  end
end
