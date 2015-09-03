require 'digest'

node.override['postgresql']['password']['postgres'] = Digest::MD5.hexdigest(rand.to_s)

include_recipe 'postgresql::server'

chef_gem 'pg' do
  compile_time false
end

connection = {
  host:     '127.0.0.1',
  port:     5432,
  username: 'postgres'
}

applications.each do |app|
  if app.database?
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

    execute "#{app} database url > dotenv" do
      command "echo DATABASE_URL=postgres:///#{app} >> #{app.dotenv_path}"
      not_if "cat #{app.dotenv_path} | grep DATABASE_URL"
    end
  end
end
