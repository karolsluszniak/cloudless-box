if applications.any?
  yum_repository 'passenger' do
    description 'Official Phusion Passenger repo'
    baseurl 'https://oss-binaries.phusionpassenger.com/yum/passenger/el/$releasever/$basearch'
    gpgkey 'https://packagecloud.io/gpg.key'
    gpgcheck false
  end

  yum_repository 'passenger-source' do
    description 'Official Phusion Passenger source repo'
    baseurl 'https://oss-binaries.phusionpassenger.com/yum/passenger/el/$releasever/SRPMS'
    gpgkey 'https://packagecloud.io/gpg.key'
    gpgcheck false
  end

  package %w{nginx passenger}

  service 'nginx' do
    action [:enable, :start]
  end

  template '/etc/nginx/conf.d/passenger.conf' do
    source 'webserver/passenger.conf.erb'
    notifies :restart, "service[nginx]", :delayed
  end

  template '/etc/nginx/nginx.conf' do
    source 'webserver/nginx.conf.erb'
    notifies :restart, "service[nginx]", :delayed
  end

  directory '/etc/nginx/sites-available'
  directory '/etc/nginx/sites-enabled'

  applications.each do |app|
    template "/etc/nginx/sites-available/#{app}" do
      source 'webserver/site.conf.erb'
      variables app: app
      notifies :restart, "service[nginx]", :delayed
    end

    link "/etc/nginx/sites-enabled/#{app}" do
      to "/etc/nginx/sites-available/#{app}"
    end
  end
end
