define :whenever_schedule, app: nil, path: nil do
  app, release_path = [params[:app], params[:path] || params[:name]]

  gem_package 'whenever'

  execute "whenever --update-crontab #{app} --set 'path=#{app.path}/current'" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end