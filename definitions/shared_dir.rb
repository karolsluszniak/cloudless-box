default_params = {
  application: nil,
  directory: nil
}

define :shared_dir, default_params do
  application = params[:application]
  directory = params[:directory] || params[:name]

  directory "#{application.shared_path}/#{directory}" do
    user application.user_name
    group application.group_name
    recursive true
  end
end
