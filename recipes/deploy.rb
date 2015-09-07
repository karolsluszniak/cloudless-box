applications.select(&:repository?).each do |app|
  deploy_revision app.name do
    repo      app.repository
    deploy_to app.path
    user      app.user_name
    group     app.group_name

    before_migrate do
      if app.ruby?
        file "#{release_path}/.ruby-version" do
          content app.ruby + "\n"
          owner app.user_name
          group app.group_name
        end
      end

      if app.bower?
        link "#{release_path}/bower_components" do
          to "#{app.shared_path}/bower_components"
        end

        execute "bower install --production" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end
      end

      if app.meteor?
        build_path = "/tmp/meteor-build-#{app}-#{release_path.split('/').last}-#{Time.now.to_i}"

        execute "meteor build #{build_path} --directory --server #{app.url_with_protocol}" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end

        execute "rm -rf #{release_path}"
        execute "mv #{build_path}/bundle #{release_path}"
        execute "rmdir #{build_path}"

        link "#{release_path}/programs/server/node_modules" do
          to "#{app.shared_path}/node_modules"
        end

        execute "npm install --production" do
          user app.user_name
          group app.group_name
          cwd "#{release_path}/programs/server"
          environment app.env
        end

        execute "mv #{release_path}/main.js #{release_path}/app.js"
      end

      if app.node?
        link "#{release_path}/node_modules" do
          to "#{app.shared_path}/node_modules"
        end

        execute "npm install --production" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end
      end

      if app.rails?
        execute "bundle install --path #{app.shared_path}/bundle --without development test" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end

        execute "bundle exec rake assets:precompile" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end
      end
    end

    before_restart do
      if app.rails?
        rbenv_execute "bundle exec rake db:migrate" do
          ruby_version app.ruby
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end
      end

      if File.exists?("#{release_path}/config/schedule.rb")
        execute "whenever --update-crontab #{app} --set 'path=#{app.path}/current'" do
          user app.user_name
          group app.group_name
          cwd release_path
          environment app.env
        end
      end
    end

    symlink_before_migrate '.env' => '.env'
    restart_command "touch #{app.path}/current/tmp/restart.txt"
    ignore_failure true
  end
end
