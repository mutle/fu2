$redis = Redis.new(:host => ENV['REDIS_SERVER'] || 'localhost', :port => (ENV['REDIS_PORT'] || 6379).to_i, :db => (ENV['REDIS_DB'] || 6).to_i)

Resque.redis = $redis
Resque.inline = ENV['RAILS_ENV'] == "test"
