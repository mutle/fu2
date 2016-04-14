class Api::EmojisController < Api::ApiController
  def index
    render text: CustomEmoji.all_emojis_cached
  end
end
