applications.each do |app|
  service app.name do
    service_name "#{app}.target"

    action :nothing
  end

  template "/usr/lib/systemd/system/#{app}.target" do
    source 'workers/application.target.erb'
    variables app: app
    notifies :restart, "service[#{app}]", :delayed
  end

  app.workers.each do |worker, info|
    template "/usr/lib/systemd/system/#{app}-#{worker}.target" do
      source 'workers/worker.target.erb'
      variables app: app, worker: worker, scale: info['scale']
      notifies :restart, "service[#{app}]", :delayed
    end

    (1..info['scale']).each do |n|
      template "/usr/lib/systemd/system/#{app}-#{worker}-#{n}.service" do
        source 'workers/worker_instance.service.erb'
        variables app: app, command: info['command']
        notifies :restart, "service[#{app}]", :delayed
      end
    end
  end
end