define :shared_dir, application: nil, directory: nil do
  application = params[:application]
  directory = params[:directory] || params[:name]

  directory "#{application.shared_path}/#{directory}" do
    user application.user_name
    group application.group_name
    recursive true
  end
end
