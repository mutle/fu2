class Api::PostsController < Api::ApiController
  before_action :load_channel, :except => [:fave, :faved, :search, :advanced_search]

  def index
    last_update = Time.at params[:last_update].to_i if params[:last_update]
    @channel.read = true
    @last_read_id = @channel.last_read_id(current_user)

    @view = Views::ChannelPosts.new({
      current_user: current_user,
      channel: @channel,
      last_read_id: @last_read_id,
      first_id: params[:first_id],
      last_id: params[:last_id],
      limit: params[:limit] || 12,
      last_update: last_update,
      site: @site
    })
    @channel.visit(current_user)
    @last_post_id = 0
    @view.finalize
    respond_with @view.posts
  end

  def create
    @post = @channel.posts.create(body: params[:post][:body], user_id: current_user.id, markdown: true, site_id: @site.id)
    @channel.visit current_user, @post.id
    # rendered = render_to_string(partial: "/channels/post", object: @post) if request.format.symbol == :json

    render "show"
  end

  def update
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
    @post.update_attributes(post_params)

    render "show"
  end

  def destroy
    @post = @channel.posts.find(params[:id].to_i)
    deleted = @post.user_id == current_user.id
    @post.destroy if deleted

    render json: {post: {deleted: deleted}}
  end

  def fave
    @post = sitePost.find(params[:id].to_i)
    @post.read = true
    emoji = params[:emoji] || "star"
    if @post.faved_by? @current_user, nil, emoji
      @post.unfave @current_user, emoji
    else
      @post.fave @current_user, emoji
    end
    render "show"
  end

  def unread
    @post_id = params[:id].to_i == 0 ? 0 : sitePost.find(params[:id].to_i).id
    @channel.visit(current_user, @post_id)
    render json: {status: "OK"}
  end

  def search
    query = params[:post][:query].to_s
    page = (params[:post][:page] || 1).to_i
    sort = params[:post][:sort] || "score"
    per_page = (params[:post][:per_page] || 25).to_i
    @view = Views::Search.new({
      query: query,
      page: page,
      sort: sort,
      type: "posts",
      per_page: per_page
    })
    @view.finalize
  end

  def advanced_search
    q = Search::PostsQuery.new
    render json: q.searchable
  end

  private
  def post_params
    params.require(:post).permit(:body)
  end

  def load_channel
    @channel = siteChannel.find(params[:channel_id].to_i)
  end
end
