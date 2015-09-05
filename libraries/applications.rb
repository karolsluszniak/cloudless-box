require 'digest'

class Chef::Recipe
  class Application
    attr_reader :name, :attributes, :node

    def initialize(name, attributes, node)
      @name = name
      @attributes = attributes
      @node = node
    end

    def bower?
      attributes["applications.#{name}.bower"]
    end

    def dotenv_path
      "#{shared_path}/.env"
    end

    def env
      @env ||= {}.tap do |vars|
        vars['DATABASE_URL'] = "postgres:///#{postgresql_db_name}" if postgresql?
        vars['HOME'] = path if node? || bower? || meteor?
        vars['MONGO_URL'] = "mongodb:///#{mongodb_db_name}" if mongodb?
        vars['NODE_ENV'] = 'production' if node?
        vars['RAILS_ENV'] = 'production' if rails?
        vars['ROOT_URL'] = url_with_protocol if meteor?
        vars['SECRET_KEY_BASE'] = secret_key_base if rails?
      end.merge(custom_env)
    end

    def env_string
      @env_string ||= env.map { |var, val| "#{var}='#{val}'" }.join(' ')
    end

    def group_name
      'deploy'
    end

    def meteor?
      layout == 'meteor'
    end

    def mongodb?
      attributes["applications.#{name}.mongodb"]
    end

    def mongodb_db_name
      name
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
      attributes["applications.#{name}.postgresql"]
    end

    def postgresql_db_name
      name
    end

    def rails?
      layout == 'rails'
    end

    def repository
      attributes["applications.#{name}.repository"]
    end

    def repository?
      repository.is_a?(String)
    end

    def repository_host
      repository? ? repository.match(/(.*@)?(.*)(:.*)/)[2] : nil
    end

    def ruby
      attributes["applications.#{name}.ruby"]
    end

    def ruby?
      ruby.is_a?(String)
    end

    def shared_path
      "#{path}/shared"
    end

    def sticky_sessions?
      meteor? || attributes["applications.#{name}.sticky_sessions"]
    end

    def to_s
      name
    end

    def url
      attributes["applications.#{name}.url"] || "#{name}.#{node['hostname']}"
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

    private

    def custom_env_prefix
      "applications.#{name}.env."
    end

    def custom_env
      @custom_env ||= begin
        vars = attributes.select { |key| key.start_with?(custom_env_prefix) }
        vars = vars.map { |key, val| [key.sub(custom_env_prefix, '').upcase, val] }
        vars.to_h
      end
    end

    def layout
      attributes["applications.#{name}.layout"].to_s
    end

    def secret_key_base
      secret(:secret_key_base)
    end

    def secret(key)
      Digest::SHA256.hexdigest([attributes['applications.secret'], group_name, name, key].join)
    end

    def unixify(string)
      string.downcase.gsub(/[_\s]+/, '-')
    end
  end

  def applications
    @applications ||= begin
      app_list = node['cloudless-box'].keys
      app_list = app_list.map { |key| (match = key.match(/^applications\.(\w+)\./)) && match[1] }
      app_list = app_list.compact.uniq

      app_list.map do |name|
        Application.new(name, node['cloudless-box'], node)
      end
    end
  end
end
