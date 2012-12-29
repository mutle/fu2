class ImagesController < ApplicationController
  before_filter :login_required
  respond_to :json

  def create
    @image = Image.create params[:image].merge(:user_id => current_user.id)
    respond_with @image
  end
end
