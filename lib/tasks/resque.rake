require 'resque/tasks'

Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }

task "resque:setup" => :environment do
end
