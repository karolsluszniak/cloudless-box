require 'securerandom'

applications.select(&:repository?).each do |app|
  if app.rails?
    %w{log pids system bundle}.each do |shared_directory|
      directory "#{app.shared_path}/#{shared_directory}" do
        user app.user_name
        group app.group_name
        recursive true
      end
    end

    execute "#{app} secret key base > dotenv" do
      command "echo SECRET_KEY_BASE=#{SecureRandom.hex(64)} >> #{app.dotenv_path}"
      not_if "cat #{app.dotenv_path} | grep SECRET_KEY_BASE"
    end
  end

  deploy_revision app.name do
    repo      app.repository
    deploy_to app.path
    user      app.user_name
    group     app.group_name

    if app.rails?
      before_migrate do
        execute "bundle install --path #{app.shared_path}/bundle --without development test" do
          cwd release_path
          user app.user_name
          group app.group_name
        end
      end

      migrate true
      migration_command 'RAILS_ENV=production bundle exec rake db:migrate'

      before_restart do
        execute "RAILS_ENV=production bundle exec rake assets:precompile" do
          cwd release_path
          user app.user_name
          group app.group_name
        end
      end
    end

    symlink_before_migrate '.env' => '.env'
    restart_command "touch #{app.path}/current/tmp/restart.txt"
    ignore_failure true
  end
end
