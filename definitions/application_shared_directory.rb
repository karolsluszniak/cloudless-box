default_params = {
  application: nil,
  directory: nil
}

define :application_shared_directory, default_params do
  directory "#{params[:application].shared_path}/#{params[:directory] || params[:name]}" do
    user params[:application].user_name
    group params[:application].group_name
    recursive true
  end
end
