applications.each do |app|
  app.shared_directories.each do |shared_directory|
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

  env_file "write env file for #{app}" do
    file app.dotenv_path
    variables app.env
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



