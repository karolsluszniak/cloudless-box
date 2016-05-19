define :update_proxy, app: nil do
  app = params[:app]

  template "/usr/lib/systemd/system/#{app}-instance.service" do
    source 'proxy/proxy_instance.service.erb'
    variables app: app
  end

  execute 'systemctl daemon-reload'

  service app.name do
    service_name "#{app}-instance.service"

    action [:enable, :stop, :start]
  end
end
