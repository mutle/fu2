class Api::PostsController < Api::ApiController
  before_filter :load_channel, :except => [:fave, :faved]

  def index
    last_update = Time.at params[:last_update].to_i if params[:last_update]
    @last_read_id = @channel.last_read_id(current_user)

    @view = Views::ChannelPosts.new({
      current_user: current_user,
      channel: @channel,
      last_read_id: @last_read_id,
      first_id: params[:first_id],
      last_id: params[:last_id],
      limit: params[:limit] || 12,
      last_update: last_update
    })
    @channel.visit(current_user)
    @last_post_id = 0
    @view.finalize
    respond_with @view.posts
  end

  def create
    @post = @channel.posts.create(body: params[:post][:body], user_id: current_user.id, markdown: current_user.markdown?)
    increment_metric "posts.all"
    increment_metric "channels.id.#{@channel.id}.posts"
    increment_metric "posts.user.#{current_user.id}"
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
    @post = Post.find(params[:id].to_i)
    if @post.faved_by? @current_user
      @post.unfave @current_user
    else
      @post.fave @current_user
    end
    render "show"
  end

  def unread
    @post_id = params[:id].to_i == 0 ? 0 : Post.find(params[:id].to_i).id
    @channel.visit(current_user, @post_id)
    render json: {status: "OK"}
  end

  private
  def post_params
    params.require(:post).permit(:body)
  end

  def load_channel
    @channel = Channel.find(params[:channel_id].to_i)
  end
end
