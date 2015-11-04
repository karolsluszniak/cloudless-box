set :output, 'log/schedule.log'

every 1.day do
  rake 'sample'
end
