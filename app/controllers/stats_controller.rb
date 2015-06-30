class StatsController < ApplicationController
  before_filter :login_required
  respond_to :json

  def websockets
    result = {connections: WebsocketServer.connection_count, users: WebsocketServer.connected_users}
    respond_with result
  end
end
