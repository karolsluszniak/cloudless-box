require 'digest'

class Chef::Recipe
  class Application
    attr_reader :node, :name, :attributes

    def initialize(node, name, attributes)
      @node = node
      @name = name
      @attributes = attributes
    end

    def app_root
      path_join(path, 'current', repository_path)
    end

    def bower?
      attributes["bower"]
    end

    def directories_created_for_release
      @directories_created_for_release ||= symlinks.values.map do |path|
        if (dirname = Pathname.new(path).dirname.to_s) != '.'
          dirname
        end
      end.compact
    end

    def directories_purged_for_release
      @directories_purged_for_release ||= symlinks.map do |source, target|
        if shared_directories.include?(source)
          target
        end
      end.compact
    end

    def dotenv_path
      "#{shared_path}/.env"
    end

    def env
      @env ||= {}.tap do |vars|
        vars['APP_ROOT'] = app_root
        vars['DATABASE_URL'] = "postgres:///#{postgresql_db_name}" if postgresql?
        vars['HOME'] = path
        vars['MONGO_URL'] = "mongodb:///#{mongodb_db_name}" if mongodb?
        vars['NODE_ENV'] = 'production' if node?
        vars['RAILS_ENV'] = 'production' if rails?
        vars['REDIS_URL'] = "redis://localhost:#{redis_port}" if redis?
        vars['ROOT_URL'] = url_with_protocol if meteor?
        vars['SECRET_KEY_BASE'] = secret_key_base if rails?
      end.merge(custom_env)
    end

    def group_name
      'deploy'
    end

    def meteor?
      layout == 'meteor'
    end

    def middleman?
      layout == 'middleman'
    end

    def mongodb?
      attributes["mongodb"]
    end

    def mongodb_db_name
      name
    end

    def nginx_options?
      nginx_options.any?
    end

    def nginx_options
      @nginx_options ||= Array(attributes['nginx']).map do |parts|
        parts.join(' ')
      end
    end

    def nginx_root
      path_join(path, 'current', public_directory)
    end

    def node?
      layout == 'node'
    end

    def passenger?
      %w{meteor node rails}.include?(layout)
    end

    def path
      "/home/#{user_name}"
    end

    def postgresql?
      attributes["postgresql"]
    end

    def postgresql_db_name
      name && name.gsub(/[^\w]/, '_')
    end

    def procfile_path
      path_join(app_root, 'Procfile')
    end

    def procfile_workers
      @procfile_workers ||= if File.exists?(procfile_path)
        File.readlines(procfile_path).map do |line|
          if (match = line.match(/([a-zA-Z0-9_]+):(.*)/))
            match[1..2].map(&:strip)
          end
        end.compact.to_h
      else
        {}
      end
    end

    def public_directory
      path_join(repository_path, attributes['public'] || (middleman? ? 'build' : 'public'))
    end

    def rails?
      layout == 'rails'
    end

    def redis?
      attributes["redis"]
    end

    def redis_port
      6380 + user_index
    end

    def release_working_directory(release_path)
      path_join(release_path, repository_path)
    end

    def repository
      attributes["repository"]
    end

    def repository?
      repository.is_a?(String)
    end

    def repository_host
      @repository_host ||= begin
        if repository.to_s.start_with? 'git'
          repository.match(/(.*@)(.*)(:.*)/)[2]
        elsif repository.to_s.start_with? 'http'
          repository.match(/(.*\:\/\/)(.*?)(\/.*)/)[2]
        end
      end
    end

    def repository_path
      attributes['repository_path']
    end

    def repository_path?
      repository_path.is_a?(String)
    end

    def ruby
      attributes["ruby"]
    end

    def ruby?
      ruby.is_a?(String)
    end

    def shared_path
      "#{path}/shared"
    end

    def shared_directories
      @shared_directories ||= begin
        custom_dirs = attributes["shared_dirs"] || []
        custom_dirs = custom_dirs.split(' ') if custom_dirs.is_a?(String)

        directories = %w{log pids system} + custom_dirs
        directories << 'bundle' if rails? || middleman?
        directories << 'node_modules' if node? || meteor?
        directories << 'bower_components' if bower?

        directories
      end
    end

    def sticky_sessions?
      meteor? || attributes["sticky_sessions"]
    end

    def symlinks
      @symlinks ||= begin
        shared_dir_map = shared_directories
        shared_dir_map = shared_dir_map.zip(Array.new(shared_dir_map.size, true)).to_h

        custom_map = attributes["symlinks"] || {}
        custom_map = custom_map.split(' ') if custom_map.is_a?(String)
        custom_map = custom_map.zip(Array.new(custom_map.size, true)).to_h if custom_map.is_a?(Array)

        mapping = {
          '.env' => true,
          'log' => true,
          'pids' => 'tmp/pids',
          'system' => path_join(public_directory, 'system')
        }

        mapping = shared_dir_map.merge(mapping).merge(custom_map)
        mapping = mapping.select { |source, target| target }

        mapping.map do |source, target|
          [source, path_join(repository_path, target.is_a?(String) ? target : source)]
        end.to_h
      end
    end

    def to_s
      name
    end

    def url
      if attributes['url'] && attributes['url'].end_with?('.')
        "#{attributes["url"]}#{node['fqdn']}"
      elsif attributes['url']
        attributes["url"]
      else
        "#{name}.#{node['fqdn']}"
      end
    end

    def url_with_protocol
      "http://#{url}"
    end

    def url?
      url.is_a?(String)
    end

    def user_name
      [group_name, unixify(name)].join('-')
    end

    def whenever_schedule
      attributes['schedule'].is_a?(String) ? attributes['schedule'] : 'config/schedule.rb'
    end

    def whenever_schedule_path
      path_join(app_root, whenever_schedule)
    end

    def whenever?
      unless attributes['schedule'] == false
        File.exists?(whenever_schedule_path)
      end
    end

    def workers
      @workers ||= begin
        procfile_workers.merge(attributes['workers'] || {}).map do |name, info|
          if info.is_a?(Fixnum)
            info = { 'command' => procfile_workers[name], 'scale' => info }
          elsif info.is_a?(String)
            info = { 'command' => info, 'scale' => 1 }
          end

          if info.is_a?(Hash)
            info = { 'command' => info['command'], 'scale' => info['scale'] }
            info['command'] ||= procfile_workers[name]
            info['scale'] ||= 1

            if info['command'].is_a?(String) && info['scale'].is_a?(Fixnum)
              [name, info]
            end
          end
        end.compact.to_h
      end
    end

    private

    def custom_env
      @custom_env ||= begin
        vars = attributes['env'] || {}
        vars = vars.map { |key, val| [key.upcase, val] }
        vars.to_h
      end
    end

    def layout
      attributes["layout"].to_s
    end

    def path_join(*parts)
      Pathname.new(parts[0].to_s).join(*parts[1..-1].map(&:to_s)).to_s
    end

    def secret_key_base
      secret(:secret_key_base)
    end

    def secret(key)
      Digest::SHA256.hexdigest(
        [attributes['secret'], node['cloudless-box']['secret'], group_name, name, key].join)
    end

    def unixify(string)
      string.downcase.gsub(/[_\s]+/, '-')
    end

    def user_index
      user_ids = File.readlines('/etc/passwd').
        select { |line| line.start_with?(group_name + '-') }.
        map { |line| (parts = line.split(':')) && [parts[0], parts[2].to_i] }.to_h

      own_id = user_ids[user_name]
      min_id = user_ids.values.min

      unless own_id
        raise("trying to access #{user_name}'s user index before account existed")
      end

      own_id - min_id
    end
  end

  def applications
    @applications ||= begin
      (node['cloudless-box']['applications'] || {}).map do |name, attributes|
        Application.new(node, name, attributes)
      end
    end
  end
end
