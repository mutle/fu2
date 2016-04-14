# This file is used by Rack-based servers to start the application.

ENV["WEBSOCKET_ALLOWED"] = "1"
require ::File.expand_path('../config/environment',  __FILE__)
run Fu2::Application
