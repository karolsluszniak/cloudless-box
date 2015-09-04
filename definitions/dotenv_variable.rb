default_params = {
  file:     nil,
  variable: nil,
  value:    nil
}

define :dotenv_variable, default_params do
  params[:variable] ||= params[:name]
  params[:variable] = params[:variable].to_s.gsub(/\s+/, '_').upcase

  execute "#{params[:name]} > dotenv" do
    command "echo #{params[:variable]}=#{params[:value]} >> #{params[:file]}"
    not_if "cat #{params[:file]} | grep #{params[:variable]}"
  end
end
