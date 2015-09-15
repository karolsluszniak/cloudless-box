applications.each do |app|
  shared_directories = %w{log pids system}
  shared_directories << 'bundle' if app.rails?
  shared_directories << 'node_modules' if app.node? || app.meteor?
  shared_directories << 'bower_components' if app.bower?

  shared_directories.each do |shared_directory|
    shared_dir(shared_directory) { app(app) }
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
    file_line var do
      file app.dotenv_path
      content "#{var}=#{val}"
      filter "#{var}="
    end
  end

  if app.ruby?
    file "#{app.path}/.ruby-version" do
      content app.ruby + "\n"
      owner app.user_name
      group app.group_name
    end

    file_line "rbenv init" do
      file app.path + '/.bash_profile'
      content 'eval "$(rbenv init -)"'
    end
  end

  file_line "dotenv export" do
    file app.path + '/.bash_profile'
    content "eval \"$(cat #{app.dotenv_path} | sed 's/^/export /')\""
  end
end
