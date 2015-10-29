require 'spec_helper'

describe 'deploy' do
  context 'middleman app' do
    describe file('/home/deploy-middleman-app/current/website/build') do
      it { should be_directory }
    end
  end

  context 'meteor app' do
    describe file('/home/deploy-node-meteor-app/shared/.env') do
      its(:content) { should match /ROOT_URL=/ }
    end
  end

  context 'node app' do
    describe file('/home/deploy-node-app/shared/.env') do
      its(:content) { should match /NODE_ENV=production/ }
    end
  end

  context 'rails app' do
    describe file('/home/deploy-rails-app/shared/.env') do
      its(:content) { should match /RAILS_ENV=production/ }
      its(:content) { should match /SECRET_KEY_BASE=\w{64}/ }
    end
  end

  context 'bower packages'
  context 'whenever schedule'
end
