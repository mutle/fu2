require 'websocket_server'

WebsocketServer.run(ENV["WEBSOCKET_PORT"] || 8000) if !Rails.env.test? && !ENV["NO_WEBSOCKETS"] && ENV["WEBSOCKET_ALLOWED"] == "1"
