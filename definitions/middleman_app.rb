define :build_middleman_app, app: nil, path: nil do
  app = params[:app]
  release_path = app.release_working_directory(params[:path] || params[:name])

  rbenv_execute "bundle install --path #{app.shared_path}/bundle --without development test" do
    ruby_version app.ruby
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end

  rbenv_execute "bundle exec middleman build" do
    ruby_version app.ruby
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end
