require 'shellwords'

default_params = {
  file:    nil,
  content: nil,
  filter:  nil
}

define :file_line, default_params do
  name = params[:name]
  file = params[:file]
  content = Shellwords.escape(params[:content] || name)
  filter = params[:filter] && Shellwords.escape(params[:filter])

  execute "file #{file} << #{name}" do
    if filter
      command "{ grep -Fv #{filter} #{file}; echo #{content}; } > #{file}"
    else
      command "echo #{content} >> #{file}"
    end

    not_if "grep -F #{filter || content} #{file}"
  end
end
