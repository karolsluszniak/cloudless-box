define :update_whenever_schedule, app: nil, path: nil do
  app = params[:app]
  release_path = app.release_working_directory(params[:path] || params[:name])

  gem_package 'whenever'

  execute "whenever --update-crontab #{app} --set 'path=#{app.app_root}'" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end
