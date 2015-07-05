class StatsController < ApplicationController
  before_filter :login_required
  respond_to :json

  def websockets
    connection_count = $redis.get("Stats:Websockets:connection-count")
    connected_users = JSON.parse($redis.get("Stats:Websockets:connected-users")) rescue {}
    result = {connections: connection_count, users: connected_users}
    respond_with result
  end
end
