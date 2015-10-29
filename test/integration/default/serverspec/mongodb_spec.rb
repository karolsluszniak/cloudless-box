require 'spec_helper'

describe 'mongodb' do
  describe service(:mongod) do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('mongo --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^MongoDB shell version: [\w\.]+$/ }
  end

  describe file('/home/deploy-node-meteor-app/shared/.env') do
    its(:content) { should match /MONGO_URL=mongodb:\/\/\/node-meteor-app/ }
  end
end
