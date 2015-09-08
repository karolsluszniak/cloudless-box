define :build_node_app, app: nil, path: nil do
  app, release_path = [params[:app], params[:path] || params[:name]]

  link "#{release_path}/node_modules" do
    to "#{app.shared_path}/node_modules"
  end

  execute "npm install --production" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end