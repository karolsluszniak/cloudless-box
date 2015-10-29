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

  describe command('curl localhost') do
    its(:stdout) { should match /Cloudless Box/ }
  end
end
