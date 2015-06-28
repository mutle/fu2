class WebsocketServer
  class << self
    def run(port)
      Thread.new do
        EM.run do
          puts "Websocket Server running on 0.0.0.0:#{port}"
          WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => port) do |ws|
            ws.onopen do
              Rails.logger.info "Websocket Client connected"
            end

            ws.onping do |message|
              puts "Ping received: #{message}"
            end

            ws.onmessage do |msg, type|
              Rails.logger.info "Websocket Received message: #{msg}"
              ws.send msg, :type => type
            end

            ws.onclose do
              Rails.logger.info "Websocket Client disconnected"
            end
          end
        end

      end

    end
  end
end
