require 'digest'

class Chef::Recipe
  class Application
    attr_reader :node, :name, :attributes

    def initialize(node, name, attributes)
      @node = node
      @name = name
      @attributes = attributes
    end

    def bower?
      attributes["bower"]
    end

    def dotenv_path
      "#{shared_path}/.env"
    end

    def env
      @env ||= {}.tap do |vars|
        vars['DATABASE_URL'] = "postgres:///#{postgresql_db_name}" if postgresql?
        vars['HOME'] = path
        vars['MONGO_URL'] = "mongodb:///#{mongodb_db_name}" if mongodb?
        vars['NODE_ENV'] = 'production' if node?
        vars['RAILS_ENV'] = 'production' if rails?
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

    def mongodb?
      attributes["mongodb"]
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
      attributes["postgresql"]
    end

    def postgresql_db_name
      name
    end

    def rails?
      layout == 'rails'
    end

    def repository
      attributes["repository"]
    end

    def repository?
      repository.is_a?(String)
    end

    def repository_host
      repository? ? repository.match(/(.*@)?(.*)(:.*)/)[2] : nil
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

    def sticky_sessions?
      meteor? || attributes["sticky_sessions"]
    end

    def to_s
      name
    end

    def url
      attributes["url"] || "#{name}.#{node['fqdn']}"
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
        vars = attributes['env'] || {}
        vars = vars.map { |key, val| [key.upcase, val] }
        vars.to_h
      end
    end

    def layout
      attributes["layout"].to_s
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
  end

  def applications
    @applications ||= begin
      (node['cloudless-box']['applications'] || {}).map do |name, attributes|
        Application.new(node, name, attributes)
      end
    end
  end
end
