require 'digest'

if (postgresql_apps = applications.select(&:postgresql?)).any?
  node.override['postgresql']['password']['postgres'] = Digest::MD5.hexdigest(rand.to_s)
  include_recipe 'postgresql::server'
  chef_gem('pg') { compile_time false }

  connection = { host: '127.0.0.1', port: 5432, username: 'postgres' }

  postgresql_apps.each do |app|
    postgresql_database_user "#{app} database owner" do
      connection connection
      username app.user_name
      action :create
    end

    postgresql_database "#{app} database" do
      connection connection
      database_name app.postgresql_db_name
      owner app.user_name
      action :create
    end
  end
end
