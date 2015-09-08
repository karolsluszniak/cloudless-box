require 'shellwords'

define :file_line, file: nil, content: nil, filter: nil, guard: nil do
  name = params[:name]
  file = params[:file]
  content = Shellwords.escape(params[:content] || name)
  filter = params[:filter] && Shellwords.escape(params[:filter])
  guard = params[:guard] && Shellwords.escape(params[:guard])

  execute "#{name} >> #{file}" do
    if filter || guard
      tmp_file = "#{file}.tmp-file-line"
      command "{ grep -Fv #{filter || guard} #{file}; echo #{content}; } > #{tmp_file}" +
              " && cat #{tmp_file} > #{file} && rm #{tmp_file}"
    else
      command "echo #{content} >> #{file}"
    end

    not_if "grep -F #{guard || content} #{file}"
  end
end
