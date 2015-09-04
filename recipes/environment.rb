require 'securerandom'

applications.select(&:repository?).each do |app|
  %w{log pids system}.each do |shared_directory|
    application_shared_directory shared_directory do
      application app
    end
  end

  if app.rails?
    application_shared_directory 'bundle' do
      application app
    end

    dotenv_variable "#{app} secret key base" do
      file app.dotenv_path
      variable :secret_key_base
      value SecureRandom.hex(64)
    end

    dotenv_variable "#{app} rails env" do
      file app.dotenv_path
      variable :rails_env
      value :production
    end
  end

  if app.node?
    application_shared_directory 'node_modules' do
      application app
    end

    dotenv_variable "#{app} node env" do
      file app.dotenv_path
      variable :node_env
      value :production
    end
  end

  if app.bower?
    application_shared_directory 'bower_components' do
      application app
    end
  end
end
