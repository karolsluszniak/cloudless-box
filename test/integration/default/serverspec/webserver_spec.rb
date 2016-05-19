require 'spec_helper'

describe 'webserver' do
  describe package(:passenger) do
    it { should be_installed }
  end

  describe service(:nginx) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe command("curl -H 'Host: meteor-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /MeteorApp/ }
  end

  describe command("curl -H 'Host: custom-middleman-app-domain.com' localhost") do
    its(:stdout) { should match /Middleman app home page/ }
  end

  describe command("curl -H 'Host: node-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /Node app home page/ }
  end

  describe command("curl -H 'Host: phoenix-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /Welcome to Phoenix!/ }
  end

  describe command("curl -H 'Host: rails-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /Rails app home page/ }
  end

  describe command("curl -H 'Host: static-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /Static app home page/ }
  end
end
