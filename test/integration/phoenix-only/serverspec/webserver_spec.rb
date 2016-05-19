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

  describe command("curl -H 'Host: phoenix-app.#{host_inventory['hostname']}' localhost") do
    its(:stdout) { should match /Welcome to Phoenix!/ }
  end
end
