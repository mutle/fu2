class WebsocketServer
  class << self
    attr_accessor :connection_count, :connected_users
    def send(conn, msg)
      conn[:socket].send(msg.to_json, type: "text")
    end

    def update_count(connections, redis)
      self.connection_count = connections.size
      users = {}
      connections.each do |c|
        users[c[:user_id]] ||= 0
        users[c[:user_id]] += 1
      end
      self.connected_users = users
      $redis.set "Stats:Websockets:connection-count", connection_count
      $redis.set "Stats:Websockets:connected-users", connected_users.to_json
    end

    def run(port)
      redis = Redis.new(:host => ENV['REDIS_SERVER'] || 'localhost', :port => (ENV['REDIS_PORT'] || 6379).to_i, :db => (ENV['REDIS_DB'] || 6).to_i)
      connections = []

      Thread.new do
        redis.subscribe('live') do |on|
          on.message do |channel,msg|
            data = JSON.parse(msg)
            user_id = data.delete('user_id')
            site_id = data.delete('site_id')
            msg = data.to_json
            connections.each do |c|
              send(c, msg) if (!site_id || c[:site_id] == site_id) && (user_id == 0 || user_id == c[:user_id])
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
                    if user && user.api_key == data['api_key']
                      site = Site.find(data['site_id'])
                      if site.user?(user)
                        Rails.logger.info "Websocket Connected: #{user.login} (#{site.id})"
                        connections.push({user_id: user.id, site_id: site.id, socket: ws})
                        update_count(connections, redis)
                      end
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
              connection = connections.find { |c| c[:socket] == ws }
              connections.delete(connection) if connection
              update_count(connections, redis)
            end
          end
        end

      end

    end
  end
end
