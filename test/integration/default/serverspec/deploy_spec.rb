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

  context 'bower packages'
  context 'whenever schedule'
end
