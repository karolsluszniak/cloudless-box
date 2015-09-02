class Chef::Recipe
  class Application
    attr_reader :app_name, :settings

    def initialize(app_name, settings)
      @app_name = app_name
      @settings = settings
    end

    def to_s
      app_name
    end

    def user_name
      [settings['applications.prefix'], app_name].join('-')
    end

    def group_name
      settings['applications.prefix']
    end

    def shared_path
      "/home/#{user_name}/shared"
    end

    def dotenv_path
      "#{shared_path}/.env"
    end
  end

  def applications
    node['cloudless-box']['applications'].map { |app_name| Application.new(app_name, node['cloudless-box']) }
  end
end