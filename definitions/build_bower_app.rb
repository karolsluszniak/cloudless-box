define :build_bower_app, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]

  link "#{release_path}/bower_components" do
    to "#{app.shared_path}/bower_components"
  end

  execute "bower install --production" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end