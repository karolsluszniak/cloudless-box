define :release_rails_app, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]

  rbenv_execute "bundle exec rake db:migrate" do
    ruby_version app.ruby
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end