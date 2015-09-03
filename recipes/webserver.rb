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
  source 'passenger.conf.erb'

  notifies :reload, "service[nginx]", :delayed
end

directory '/etc/nginx/sites-available'
directory '/etc/nginx/sites-enabled'

applications.select(&:url?).each do |app|
  template "/etc/nginx/sites-available/#{app}" do
    source 'nginx_site.erb'
    variables url: app.url, ruby_version: app.ruby, path: app.path
  end

  link "/etc/nginx/sites-enabled/#{app}" do
    to "/etc/nginx/sites-available/#{app}"

    notifies :reload, "service[nginx]", :delayed
  end
end


