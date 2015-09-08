define :build_bower_app, app: nil, path: nil do
  app, release_path = [params[:app], params[:path] || params[:name]]

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