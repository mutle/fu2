class Api::EmojisController < Api::ApiController
  def index
    render json: Emoji.all.map { |e| {aliases: e.aliases, tags: e.tags, unicode_aliases: e.unicode_aliases, image: e.image_filename} }
  end
end
