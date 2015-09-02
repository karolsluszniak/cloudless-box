applications.each do |app|
  group app.group_name

  user app.user_name do
    group app.group_name
  end

  directory app.shared_path do
    owner app.user_name
    group app.group_name
  end

  file app.dotenv_path do
    owner app.user_name
    group app.group_name
  end
end
