class UploadsController < ApplicationController
  
  before_filter :login_required
  
  def index
    @upload = Upload.new
    @uploads = current_user.uploads
  end
  
  def show
    @upload = Upload.find params[:id]
  end
  
  def create
    if params[:upload]
      @upload = Upload.new params[:upload].merge(:user_id => current_user.id)
      @upload.save!
    
      redirect_to upload_path(@upload)
    end
  end
  
end
