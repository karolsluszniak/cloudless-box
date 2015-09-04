applications.select(&:repository?).each do |app|
  default_env = {
    'RAILS_ENV' => 'production',
    'NODE_ENV' => 'production',
    'HOME' => app.path
  }

  deploy_revision app.name do
    repo      app.repository
    deploy_to app.path
    user      app.user_name
    group     app.group_name

    before_migrate do
      if app.bower?
        link "#{release_path}/bower_components" do
          to "#{app.shared_path}/bower_components"
        end

        execute "bower install --production" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment default_env
        end
      end

      if app.rails?
        execute "bundle install --path #{app.shared_path}/bundle --without development test" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment default_env
        end
      end

      if app.node?
        link "#{release_path}/node_modules" do
          to "#{app.shared_path}/node_modules"
        end

        execute "npm install --production" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment default_env
        end
      end
    end

    if app.postgresql_database? && app.rails?
      migrate true
      migration_command 'RAILS_ENV=production bundle exec rake db:migrate'
    end

    before_restart do
      if app.rails?
        execute "bundle exec rake assets:precompile" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment default_env
        end
      end
    end

    symlink_before_migrate '.env' => '.env'
    restart_command "touch #{app.path}/current/tmp/restart.txt"
    ignore_failure true
  end
end
