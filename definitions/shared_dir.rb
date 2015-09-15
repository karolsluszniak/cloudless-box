define :shared_dir, app: nil, directory: nil do
  app = params[:app]
  directory = params[:directory] || params[:name]

  directory "#{app.shared_path}/#{directory}" do
    user app.user_name
    group app.group_name
    recursive true
  end
end
