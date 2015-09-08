define :build_node_app, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]

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