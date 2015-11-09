define :update_workers, app: nil do
  app = params[:app]

  template "/usr/lib/systemd/system/#{app}.target" do
    source 'workers/application.target.erb'
    variables app: app
  end

  app.workers.each do |worker, info|
    template "/usr/lib/systemd/system/#{app}-#{worker}.target" do
      source 'workers/worker.target.erb'
      variables app: app, worker: worker, scale: info['scale']
    end

    (1..info['scale']).each do |n|
      template "/usr/lib/systemd/system/#{app}-#{worker}-#{n}.service" do
        source 'workers/worker_instance.service.erb'
        variables app: app, command: info['command']
      end
    end
  end

  execute 'systemctl daemon-reload'

  service app.name do
    service_name "#{app}.target"

    action [:enable, :stop, :start]
  end
end
