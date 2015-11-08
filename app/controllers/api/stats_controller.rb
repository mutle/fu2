class Api::StatsController < Api::ApiController
  def websockets
    connection_count = $redis.get("Stats:Websockets:connection-count")
    connected_users = JSON.parse($redis.get("Stats:Websockets:connected-users")) rescue {}
    result = {connections: connection_count, users: connected_users}
    render json: result
  end
end
