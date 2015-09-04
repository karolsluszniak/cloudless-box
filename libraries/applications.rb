class Chef::Recipe
  class Application
    attr_reader :name, :attributes

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end

    def to_s
      name
    end

    def user_name
      [group_name, name].join('-')
    end

    def group_name
      attributes['applications.prefix']
    end

    def path
      "/home/#{user_name}"
    end

    def ruby
      attributes["applications.#{name}.ruby"]
    end

    def ruby?
      ruby.is_a?(String)
    end

    def layout
      attributes["applications.#{name}.layout"]
    end

    def rails?
      layout.to_s == 'rails'
    end

    def node?
      layout.to_s == 'node'
    end

    def bower?
      attributes["applications.#{name}.bower"]
    end

    def shared_path
      "#{path}/shared"
    end

    def dotenv_path
      "#{shared_path}/.env"
    end

    def postgresql_database?
      attributes["applications.#{name}.database"].to_s.include? 'postgresql'
    end

    def repository
      attributes["applications.#{name}.repository"]
    end

    def repository_host
      repository.match(/(.*@)?(.*)(:.*)/)[2]
    end

    def repository?
      repository.is_a?(String)
    end

    def url
      attributes["applications.#{name}.url"]
    end

    def url?
      url.is_a?(String)
    end
  end

  def applications
    node['cloudless-box']['applications'].map do |name|
      Application.new(name, node['cloudless-box'])
    end
  end
end
