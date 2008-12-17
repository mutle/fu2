require 'yaml'

namespace :migration do
  
  task :dump => :environment do
    MODELS = [Channel, ChannelUser, ChannelVisit, Invite, Message, Post, Stylesheet, Upload, User]
    `mkdir -p db/bootstrap`
    MODELS.each do |model|
      out = model.all.inject({}) { |m,x| m[x.id] = x.attributes; m }
      File.open("db/bootstrap/#{model.name.underscore.pluralize}.yml", "w") { |f| f.write out.to_yaml }
    end
  end
  
  task :load => ["db:migrate", :environment] do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', '*.{yml,csv}'))).each do |fixture_file|
      Fixtures.create_fixtures('db/bootstrap', File.basename(fixture_file, '.*'))
    end
  end
end