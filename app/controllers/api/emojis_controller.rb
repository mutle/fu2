class Api::EmojisController < Api::ApiController
  def index
    render json: CustomEmoji.all_emojis
  end
end
