(node['cloudless-box']['packages'] || {}).map do |name, _|
  package name
end
