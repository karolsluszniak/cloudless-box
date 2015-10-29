require 'spec_helper'

describe 'environment' do
  describe file('/home/deploy-node-app/shared/system') do
    it { should be_directory }
  end

  describe file('/home/deploy-node-app/shared/.env') do
    it { should be_file }
    its(:content) { should match /HOME=/ }
  end

  describe file('/home/deploy-rails-app/.ruby-version') do
    it { should be_file }
    its(:content) { should match /^[\w\.]+$/ }
  end
end
