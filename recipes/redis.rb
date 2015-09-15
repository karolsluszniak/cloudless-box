if (redis_apps = applications.select(&:redis?)).any?
  node.override['redisio']['package_install'] = true
  node.override['redisio']['bin_path'] = '/usr/bin'
  node.override['redisio']['servers'] = redis_apps.map do |app|
    { 'port' => app.redis_port, 'name' => app.name.scan(/[a-z]/).join }
  end

  include_recipe 'redisio::default'
  include_recipe 'redisio::enable'
end
