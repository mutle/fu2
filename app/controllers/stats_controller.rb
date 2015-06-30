class StatsController < ApplicationController
  before_filter :login_required
  respond_to :json

  def websockets
    connection_count = $redis.get("Stats:Websockets:connection-count")
    connected_users = JSON.parse($redis.get("Stats:Websockets:connected-users")) rescue {}
    result = {connections: WebsocketServer.connection_count, users: WebsocketServer.connected_users}
    respond_with result
  end
end
