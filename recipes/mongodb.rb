if applications.find(&:mongodb?)
  include_recipe 'mongodb::default'
end
