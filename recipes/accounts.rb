at_compile_time do
  applications.each do |app|
    group app.group_name

    user app.user_name do
      group app.group_name
    end

    directory app.path do
      mode '0755'
    end
  end
end
