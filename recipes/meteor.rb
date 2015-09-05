if applications.find(&:meteor?)
  execute 'curl https://install.meteor.com/ | sh' do
    creates '/usr/local/bin/meteor'
  end
end