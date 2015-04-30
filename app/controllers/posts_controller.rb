class PostsController < ApplicationController

  layout :default_layout
  before_filter :login_required
  before_filter :load_channel, :except => [:fave, :faved]

  respond_to :html, :json

  def index
    last_update = Time.at params[:last_update].to_i if params[:last_update]
    @last_read_id = @channel.last_read_id(current_user)

    @view = Views::ChannelPosts.new({
      current_user: current_user,
      channel: @channel,
      last_read_id: @last_read_id,
      first_id: params[:first_id],
      last_id: params[:last_id],
      limit: params[:limit],
      last_update: last_update
    })
    @last_post_id = 0
    @view.finalize
    respond_with @view.posts
  end

  def create
    @post = @channel.posts.create(:body => params[:post][:body], :user_id => current_user.id, :markdown => current_user.markdown?)
    notification :post_create, @post
    increment_metric "posts.all"
    increment_metric "channels.id.#{@channel.id}.posts"
    increment_metric "posts.user.#{current_user.id}"
    @channel.visit current_user, @post.id

    respond_with @post do |f|
      f.html { redirect_to channel_path(@channel, :anchor => "post_#{@post.id}") }
      f.json { render :json => @post.as_json.merge(:rendered => render_to_string(:partial => "/channels/post", :object => @post)) }
    end
  end

  def edit
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
  end

  def update
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
    @post.update_attributes(post_params)
    notification :post_update, @post

    redirect_to channel_path(@channel, :anchor => "post_#{@post.id}")
  end

  def destroy
    @post = @channel.posts.find(params[:id].to_i)
    notification :post_destroy, @post
    @post.destroy if @post.user_id == current_user.id

    redirect_to channel_path(@channel)
  end

  def fave
    @post = Post.find(params[:id].to_i)
    if @post.faved_by? @current_user
      @post.unfave @current_user
      notification :post_unfave, @post
    else
      @post.fave @current_user
      notification :post_fave, @post
    end
    render :json => {:status => @post.faved_by?(@current_user), :count => @post.faves.count}
  end

  def unread
    @post_id = params[:id].to_i == 0 ? 0 : Post.find(params[:id].to_i).id
    @channel.visit(current_user, @post_id)
    render :json => {:status => "OK"}
  end

  def faved
    @faves = Fave.most_popular.to_a.uniq { |i| i.post_id }
  end

  private
  def post_params
    params.require(:post).permit(:body)
  end

  def load_channel
    @channel = Channel.find(params[:channel_id].to_i)
  end

  def default_layout
    return false if params[:action] == "index"
    "application"
  end

end
