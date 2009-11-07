clear_sources
source "http://gemcutter.org"
bundle_path "vendor/bundler_gems"

gem "rails", "2.3.4"
gem "pg"
gem "haml"

gem "chronic"

only :development do
  gem "unicorn"
end

only :test do
  gem "rspec"
  gem "rspec-rails"
end

disable_system_gems
