class Api::ApiController < ApplicationController
  before_action :login_required
  respond_to :json

  def info
    render json: {version: "1.0"}
  end
end
