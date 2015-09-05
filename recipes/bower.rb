if applications.find(&:bower?)
  execute 'npm install -g bower' do
    creates '/bin/bower'
  end
end
