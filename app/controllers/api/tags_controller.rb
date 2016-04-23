class Api::TagsController < Api::ApiController

  def posts
    @tag = params[:id]
    last_update = Time.at params[:last_update].to_i if params[:last_update]

    @view = Views::ChannelPosts.new({
      current_user: current_user,
      tag: @tag,
      first_id: params[:first_id],
      last_id: params[:last_id],
      limit: params[:limit] || 12,
      last_update: last_update,
      site: @site
    })
    @last_post_id = 0
    @view.finalize
    render "api/posts/index"
  end

end
