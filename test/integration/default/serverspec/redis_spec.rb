require 'spec_helper'

describe 'redis' do
  describe service(:redisrailsapp) do
    it { should be_enabled }
  end

  describe command('service redisrailsapp status') do
    its(:stdout) { should match /should be running/ }
  end

  describe command('redis-server --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^Redis server/ }
  end

  describe file('/home/deploy-rails-app/shared/.env') do
    its(:content) { should match /REDIS_URL=redis:\/\/localhost:6383/ }
  end

  describe port(6383) do
    it { should be_listening }
  end

  describe command('redis-cli -p 6383 ping') do
    its(:stdout) { should match /^PONG$/ }
  end
end
