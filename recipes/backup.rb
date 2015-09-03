bucket            = node['cloudless-box']['backup.bucket']
access_key_id     = node['cloudless-box']['backup.access_key_id']
secret_access_key = node['cloudless-box']['backup.secret_access_key']

if bucket && access_key_id && secret_access_key
  name = node['name'] || 'cloudless-box'
  backup_base_path = '/root'
  backup_path = "#{backup_base_path}/backup"
  postgresql_database = applications.find(&:postgresql_database?)

  package 'ruby-devel'
  gem_package 'backup'
  gem_package 'whenever'

  directory backup_path
  directory "#{backup_path}/config"
  directory "#{backup_path}/models"

  template "#{backup_path}/config.rb" do
    source 'backup/config.rb.erb'
  end

  template "#{backup_path}/config/schedule.rb" do
    source 'backup/schedule.rb.erb'
    variables backup_path: backup_path
  end

  template "#{backup_path}/models/master.rb" do
    source 'backup/master.rb.erb'
    variables name: name,
              bucket: bucket,
              access_key_id: access_key_id,
              secret_access_key: secret_access_key,
              postgresql_database: postgresql_database
  end

  execute 'whenever --update-crontab' do
    cwd backup_path
  end

  service 'crond' do
    action [:enable, :start]
  end
end