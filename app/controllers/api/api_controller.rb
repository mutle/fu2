class Api::ApiController < ApplicationController
  before_action :login_required, :update_active
  respond_to :json

  def info
    render json: {version: "1.0"}
  end

  def update_active
    current_user.record_active
  end
end
