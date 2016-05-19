(node['cloudless-box']['gems'] || {}).map do |name, _|
  gem_package name
end
