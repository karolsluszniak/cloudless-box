applications.each do |app|
  execute "#{app} ssh-keygen" do
    user    app.user_name
    group   app.group_name
    creates "/home/#{app.user_name}/.ssh/id_rsa.pub"
    command "ssh-keygen -t rsa -q -f #{app.path}/.ssh/id_rsa -P \"\" -C deploy-#{app}"
  end

  if app.repository?
    ssh_known_hosts "#{app} repository host: #{app.repository_host}" do
      host app.repository_host
      hashed true
      user app.user_name
    end
  end
end
