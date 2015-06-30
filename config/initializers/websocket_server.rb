require 'websocket_server'

WebsocketServer.run(ENV["WEBSOCKET_PORT"] || 8000)
