require 'spec_helper'

describe 'deploy' do
  context 'middleman app' do
    describe file('/home/deploy-middleman-app/current/test/apps/middleman-app/build') do
      it { should be_directory }
    end
  end

  context 'meteor app' do
    describe file('/home/deploy-meteor-app/shared/.env') do
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

  context 'static app' do
    describe file('/home/deploy-static-app/shared/articles') do
      it { should be_directory }
    end

    describe file('/home/deploy-static-app/current/test/apps/static-app/about.html') do
      it { should be_symlink }
      it { should be_linked_to '/home/deploy-static-app/shared/about.html' }
    end

    describe file('/home/deploy-static-app/current/test/apps/static-app/articles/index.html') do
      it { should be_symlink }
      it { should be_linked_to '/home/deploy-static-app/shared/article_index.html' }
    end

    describe file('/home/deploy-static-app/current/test/apps/static-app/categories/index.html') do
      it { should be_symlink }
      it { should be_linked_to '/home/deploy-static-app/shared/category_index.html' }
    end
  end

  context 'bower packages' do
    describe file('/home/deploy-node-app/shared/bower_components/jquery') do
      it { should be_directory }
    end
  end

  context 'whenever' do
    describe cron do
      it { should have_entry("0 0 * * * /bin/bash -l -c 'cd /home/deploy-rails-app/current/test/apps/rails-app && RAILS_ENV=production bundle exec rake sample --silent >> log/schedule.log 2>&1'").with_user('deploy-rails-app') }
    end
  end

  context 'workers' do
    describe service('rails-app.target') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('rails-app-sidekiq.target') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('rails-app-sidekiq-1.service') do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('ps aux | grep "rake infinite" | grep -v grep | wc -l') do
      its(:stdout) { should match /^2$/ }
    end

    describe command('ps aux | grep "sidekiq" | grep -v grep | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
end
