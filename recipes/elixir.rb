node.override['erlang']['esl']['version'] = "18.3-1"
node.override['elixir']['version'] = "1.2.5"

if (elixir_apps = applications.select(&:elixir?)).any?
  include_recipe 'elixir::default'
end
