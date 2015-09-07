if (ruby_apps = applications.select(&:ruby?)).any?
  node.override['rbenv']['group_users'] = applications.select(&:ruby?).map(&:user_name)

  include_recipe "rbenv::default"
  include_recipe "rbenv::ruby_build"

  ruby_apps.map(&:ruby).uniq.each do |ruby_version|
    rbenv_ruby ruby_version

    rbenv_gem 'bundler' do
      ruby_version ruby_version
    end
  end
end

if applications.find(&:whenever?)
  gem_package 'whenever'
end
