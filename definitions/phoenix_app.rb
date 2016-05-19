define :build_phoenix_app, app: nil, path: nil do
  app = params[:app]
  release_path = app.release_working_directory(params[:path] || params[:name])

  [ "node_modules",
    "deps"
  ].each do |path|
    link "#{release_path}/#{path}" do
      to "#{app.shared_path}/#{path}"
    end
  end

  [ "mix local.hex --force",
    "mix local.rebar --force",
    "mix deps.get --only prod",
    "mix compile",
    "npm install --production",
    "node_modules/brunch/bin/brunch build --production",
    "mix phoenix.digest"
  ].each do |command|
    execute command do
      user app.user_name
      group app.group_name
      cwd release_path
      environment app.env
    end
  end
end

define :release_phoenix_app, app: nil, path: nil do
  app = params[:app]
  release_path = app.release_working_directory(params[:path] || params[:name])

  execute "mix ecto.migrate" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end
