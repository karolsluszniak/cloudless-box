if node['cloudless-box']['firewall'] != false
  include_recipe 'iptables::default'

  %w{http ssh}.each do |rule|
    iptables_rule "#{rule}" do
      source "firewall/#{rule}.erb"
      action :enable
    end
  end
end
