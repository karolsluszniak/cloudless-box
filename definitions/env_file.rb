define :env_file, file: nil, variables: nil do
  file = params[:file]
  variables = params[:variables]

  variables.each do |var, val|
    file_line var do
      file file
      content "#{var}=#{val}"
      filter "#{var}="
    end
  end
end
