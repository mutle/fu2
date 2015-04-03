require 'cjsx'

Fu2::Application.assets.register_engine '.cjsx', React::CJSX::Template
Fu2::Application.config.watchable_files.concat Dir["#{Fu2::Application.root}/app/assets/javascripts/**/*.cjsx*"]
