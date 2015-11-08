class NotificationsController < ApplicationController

  before_filter :login_required

  respond_to :html, :json

  def index
    empty_response
  end

end
