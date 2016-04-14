class Api::ImagesController < Api::ApiController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    @image = siteImage.create image_params.merge(:user_id => current_user.id)
    render json: @image.as_json
  end

  private
  def image_params
    params.require(:image).permit(:filename, :image_file, :user_id)
  end
end
