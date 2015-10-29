require 'spec_helper'

describe 'certificates' do
  describe file('/home/deploy-node-app/.ssh/id_rsa') do
    it { should exist }
  end
end
