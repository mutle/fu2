worker_pool 5
queue '*'

before_fork do
  require "./config/environment.rb"
  Rails.application.eager_load!
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |resque_worker|
  ActiveRecord::Base.establish_connection
end
