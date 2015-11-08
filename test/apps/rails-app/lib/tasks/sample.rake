task :sample do
  puts "Sample task executed at #{Time.now}"
end

task :infinite do
  puts "Infinite task executed at #{Time.now}"

  begin
    while true do
      sleep 60
    end
  rescue Exception => e
    puts "Infinite task terminated at #{Time.now}"
  end
end

task :job => :environment do
  puts "Job task executed at #{Time.now}"

  SampleJob.perform_later(123, 'abc')
  sleep 5

  puts "Job task slept 5 seconds and terminated at #{Time.now}"
end
