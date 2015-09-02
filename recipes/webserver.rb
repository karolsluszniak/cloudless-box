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
