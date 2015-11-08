class SampleJob < ActiveJob::Base
  def perform(*args)
    puts "Sample job executed at #{Time.now} with arguments #{args.inspect}"
  end
end