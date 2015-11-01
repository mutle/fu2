class Api::ImagesController < Api::ApiController
  before_filter :login_required
  respond_to :json

  def create
    @image = Image.create image_params.merge(:user_id => current_user.id)
    respond_with @image
  end

  private
  def image_params
    params.require(:image).permit(:filename, :image_file, :user_id)
  end
end
