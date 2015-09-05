applications.each do |app|
  shared_directories = %w{log pids system}
  shared_directories << 'bundle' if app.rails?
  shared_directories << 'node_modules' if app.node?
  shared_directories << 'bower_components' if app.bower?

  shared_directories.each do |shared_directory|
    application_shared_directory shared_directory do
      application app
    end
  end

  directory app.shared_path do
    owner app.user_name
    group app.group_name
  end

  file app.dotenv_path do
    owner app.user_name
    group app.group_name
    mode '0700'
  end

  app.env.each do |var, val|
    dotenv_variable "#{app} #{var}" do
      file app.dotenv_path
      variable var
      value val
    end
  end
end
