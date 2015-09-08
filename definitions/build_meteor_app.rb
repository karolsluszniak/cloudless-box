define :build_meteor_app, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]
  build_path = "/tmp/meteor-build-#{app}-#{release_path.split('/').last}-#{Time.now.to_i}"

  execute "meteor build #{build_path} --directory --server #{app.url_with_protocol}" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end

  execute "rm -rf #{release_path}"
  execute "mv #{build_path}/bundle #{release_path}"
  execute "rmdir #{build_path}"

  link "#{release_path}/programs/server/node_modules" do
    to "#{app.shared_path}/node_modules"
  end

  execute "npm install --production" do
    user app.user_name
    group app.group_name
    cwd "#{release_path}/programs/server"
    environment app.env
  end

  execute "mv #{release_path}/main.js #{release_path}/app.js"
end