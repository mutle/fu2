require 'trashed/railtie'
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Fu2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['TZ'] if ENV['TZ']

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'


    config.action_dispatch.default_headers = {
      'X-XSS-Protection' => '0'
    }

    METRICS = Statsd.new(ENV['STATSD_HOST'] || 'localhost', 8125)
    METRICS.namespace = "fu2"
    
    config.trashed.statsd = METRICS

    config.trashed.timing_dimensions = ->(env) do
      # Rails 3 and 4 set this. Other Rack endpoints won't have it.
      if controller = env['action_controller.instance']
        name    = controller.controller_name
        action  = controller.action_name
        format  = controller.rendered_format || :none
        variant = controller.request.variant || :none  # Rails 4.1+ only!

        [ :All,
          :"Controllers.#{name}",
          :"Actions.#{name}.#{action}.#{format}+#{variant}" ]
      end
    end
  end

  def self.time_format
    "%Y/%m/%d %H:%M"
  end
end
