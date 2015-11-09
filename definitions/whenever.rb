define :update_whenever, app: nil do
  app = params[:app]

  options = {
    'update-crontab' => app.name,
    'set' => [:path, app.app_root].join('='),
    'load-file' => app.whenever_schedule
  }.map { |var, val| "--#{var} '#{val}'" }.join(' ')

  gem_package 'whenever'

  execute "whenever #{options}" do
    user app.user_name
    group app.group_name
    cwd app.app_root
    environment app.env
  end
end
