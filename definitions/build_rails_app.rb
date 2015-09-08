define :build_rails_app, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]

  rbenv_execute "bundle install --path #{app.shared_path}/bundle --without development test" do
    ruby_version app.ruby
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end

  rbenv_execute "bundle exec rake assets:precompile" do
    ruby_version app.ruby
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end