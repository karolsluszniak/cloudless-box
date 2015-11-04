class HomeController < ApplicationController
  def show
    @user_count = User.count
    @redis_status = Redis.new(url: ENV['REDIS_URL']).set('key', 'value')
  end
end
