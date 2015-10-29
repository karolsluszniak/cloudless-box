require 'spec_helper'

describe 'accounts' do
  describe user('deploy-node-app') do
    it { should exist }
    it { should belong_to_group 'deploy' }
    it { should have_home_directory '/home/deploy-node-app' }
  end
end
