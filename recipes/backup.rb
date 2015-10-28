if backup_attributes = node['cloudless-box']['backup']
  bucket            = backup_attributes['bucket']
  access_key_id     = backup_attributes['access_key_id']
  secret_access_key = backup_attributes['secret_access_key']

  if bucket && access_key_id && secret_access_key
    name = node['name'] || node.name || node.chef_environment || 'cloudless-box'
    backup_base_path = '/root'
    backup_path = "#{backup_base_path}/backup"
    postgresql = applications.find(&:postgresql?)
    mongodb = applications.find(&:mongodb?)

    package 'ruby-devel'
    package 'bzip2'
    gem_package 'backup'
    gem_package 'whenever'

    directory backup_path
    directory "#{backup_path}/config"
    directory "#{backup_path}/models"

    template "#{backup_path}/config.rb" do
      source 'backup/config.rb.erb'
    end

    template "#{backup_path}/models/master.rb" do
      source 'backup/master.rb.erb'
      variables name:               name,
                bucket:             bucket,
                access_key_id:      access_key_id,
                secret_access_key:  secret_access_key,
                postgresql:         postgresql,
                mongodb:            mongodb
    end

    template "#{backup_path}/config/schedule.rb" do
      source 'backup/schedule.rb.erb'
      variables backup_path: backup_path
      notifies :run, 'execute[whenever --update-crontab]'
    end

    template '/etc/sudoers' do
      source 'backup/sudoers.erb'
    end

    execute 'whenever --update-crontab' do
      cwd backup_path
      action :nothing
    end

    service 'crond' do
      action [:enable, :start]
    end
  end
end
