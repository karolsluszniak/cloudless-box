require 'digest'

if (postgresql_apps = applications.select(&:postgresql_database?)).any?
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
      database_name app.name
      owner app.user_name
      action :create
    end

    dotenv_variable "#{app} database url" do
      file app.dotenv_path
      variable :database_url
      value "postgres:///#{app}"
    end
  end
end
