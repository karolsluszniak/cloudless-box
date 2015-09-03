class Chef::Recipe
  class Application
    attr_reader :name, :settings

    def initialize(name, settings)
      @name = name
      @settings = settings
    end

    def to_s
      name
    end

    def user_name
      [group_name, name].join('-')
    end

    def group_name
      settings['applications.prefix']
    end

    def path
      "/home/#{user_name}"
    end

    def ruby
      settings["applications.#{name}.ruby"]
    end

    def ruby?
      ruby.is_a?(String)
    end

    def layout
      settings["applications.#{name}.layout"]
    end

    def rails?
      layout.to_s == 'rails'
    end

    def shared_path
      "#{path}/shared"
    end

    def dotenv_path
      "#{shared_path}/.env"
    end

    def database?
      settings["applications.#{name}.database"]
    end

    def repository
      settings["applications.#{name}.repository"]
    end

    def repository_host
      repository.match(/(.*@)?(.*)(:.*)/)[2]
    end

    def repository?
      repository.is_a?(String)
    end

    def url
      settings["applications.#{name}.url"]
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
