applications.select(&:repository?).each do |app|
  deploy_revision app.name do
    repo      app.repository
    deploy_to app.path
    user      app.user_name
    group     app.group_name

    before_migrate do
      build_bower_app(release_path) { application(app) } if app.bower?
      build_meteor_app(release_path) { application(app) } if app.meteor?
      build_node_app(release_path) { application(app) } if app.node?
      build_rails_app(release_path) { application(app) } if app.rails?
    end

    before_restart do
      release_rails_app(release_path) { application(app) } if app.rails?
      whenever_schedule(release_path) { application(app) } if app.whenever?
    end

    symlink_before_migrate '.env' => '.env'
    restart_command "touch #{app.path}/current/tmp/restart.txt"
    ignore_failure true
  end
end
