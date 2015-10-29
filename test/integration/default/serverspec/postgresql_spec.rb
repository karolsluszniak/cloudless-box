require 'spec_helper'

describe 'posgresql' do
  describe service(:postgresql) do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('psql --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^psql \(PostgreSQL\) [\w\.]+$/ }
  end

  describe file('/home/deploy-rails-app/shared/.env') do
    its(:content) { should match /DATABASE_URL=postgres:\/\/\/rails-app/ }
  end
end
