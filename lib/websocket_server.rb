class WebsocketServer
  class << self
    def send(conn, msg)
      conn[:socket].send(msg.to_json, type: "text")
    end

    def run(port)
      redis = Redis.new(:host => ENV['REDIS_SERVER'] || 'localhost', :port => (ENV['REDIS_PORT'] || 6379).to_i, :db => (ENV['REDIS_DB'] || 6).to_i)
      connections = []

      Thread.new do
        redis.subscribe('live') do |on|
          on.message do |channel,msg|
            data = JSON.parse(msg)
            user_id = data.delete('user_id')
            msg = data.to_json
            connections.each do |c|
              send(c, msg) if user_id == 0 || user_id == c[:user_id]
            end
          end
        end
      end

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
              if type == :text
                begin
                  data = JSON.parse(msg)
                  Rails.logger.info "Websocket Received message: #{data}"
                  if data['type'] == "auth"
                    user = User.with_api_key(data['api_key']).first
                    if user
                      Rails.logger.info "Websocket Connected: #{user.login}"
                      connections.push({user_id: user.id, socket: ws})
                    end
                  end
                rescue => e
                  Rails.logger.error "Websocket Parse message failed: #{msg} #{e.message}"
                end
              else
                Rails.logger.error "Websocket Unhandled message: #{msg} #{type}"
              end
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
