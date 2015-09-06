if node['cloudless-box']['firewall']
  include_recipe 'iptables::default'

  if rules = node['cloudless-box']['firewall']['rules']
    rules.each do |rule|
      iptables_rule "#{rule}" do
        source "firewall/#{rule}.erb"
        action :enable
      end
    end
  end
end