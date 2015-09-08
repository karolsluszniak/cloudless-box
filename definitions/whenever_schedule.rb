define :whenever_schedule, application: nil do
  app = params[:application]
  release_path = params[:path] || params[:name]

  gem_package 'whenever'

  execute "whenever --update-crontab #{app} --set 'path=#{app.path}/current'" do
    user app.user_name
    group app.group_name
    cwd release_path
    environment app.env
  end
end