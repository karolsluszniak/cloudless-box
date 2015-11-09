applications.select(&:repository?).each do |app|
  deploy_revision app.name do
    repo      app.repository
    deploy_to app.path
    user      app.user_name
    group     app.group_name

    before_migrate do
      install_bower_packages(release_path) { app(app) } if app.bower?

      build_middleman_app(release_path) { app(app) } if app.middleman?
      build_meteor_app(release_path) { app(app) } if app.meteor?
      build_node_app(release_path) { app(app) } if app.node?
      build_rails_app(release_path) { app(app) } if app.rails?
    end

    before_restart do
      release_rails_app(release_path) { app(app) } if app.rails?
    end

    after_restart do
      update_whenever { app(app) } if app.whenever?
      update_workers { app(app) }
    end

    symlink_before_migrate({})
    purge_before_symlink app.directories_purged_for_release
    create_dirs_before_symlink app.directories_created_for_release
    symlinks app.symlinks
    restart_command do
      file "#{app.release_working_directory(release_path)}/tmp/restart.txt" do
        action :touch
      end
    end
    ignore_failure true
  end
end
