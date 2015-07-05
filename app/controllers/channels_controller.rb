class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper

  before_filter :login_required
  before_filter :channel_redirect, only: [:show]

  respond_to :html, :json

  def index(respond=true)
    @page = (params[:page] || 1).to_i
    @view = Views::ChannelList.new({
      current_user: current_user,
      page: @page
    })
    @action = 'channels'
    @view.finalize
    if respond
      respond_with @view.recent_channels
    end
  end

  def live
    if Post.most_recent.first.id > params[:last_id].to_i
      index(false)
      render :partial => "channels", :layout => false
    else
      render :text => ""
    end
  end

  def show
    if params[:id] == "all"
      all
    else
      posts(false)
      respond_with @channel
    end
  end

  def all
    @view = Views::AllChannels.new({
      current_user: current_user,
      page: (params[:page] || 1).to_i,
      letter: params[:letter]
    })
    @view.finalize
    render "all"
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.create(channel_params.merge(:user_id => current_user.id, :markdown => current_user.markdown?))
    if @channel.valid?
      Live.channel_create(@channel)
      increment_metric "posts.all"
      increment_metric "posts.user.#{current_user.id}"
      increment_metric "channels.all"
      increment_metric "channels.id.#{@channel.id}.posts"
      increment_metric "channels.user.#{current_user.id}"

      respond_with @channel do |f|
        f.html { redirect_to channel_path(@channel) }
        f.json { respond_with @channel }
      end
    else

      @post = Post.new(body: channel_params[:body])
      @channel.body = @post.body
      respond_with @channel do |f|
        f.html { render "new" }
        f.json { render :json => @channel.errors }
      end
    end
  end

  def update
    @channel = Channel.find params[:id]
    channel = params[:channel]
    @channel.text = channel[:text]
    @channel.rename(channel[:title], @current_user)
    @channel.updated_by = current_user.id
    @channel.save
    redirect_to channel_path(@channel)
  end

  def visit
    @channel = Channel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    render json: {last_read: @last_read_id}
  end

  def merge
    @channel = Channel.find params[:id]
    @view = Views::ChannelMerge.new({
      current_user: current_user,
      channel: @channel
    })
    @view.finalize
  end

  def do_merge
    @channel = Channel.find params[:id]
    @other_channel = Channel.find params[:merge_id]
    @channel.merge(@other_channel, current_user)
    redirect_to channel_path(@channel)
  end

  private
  def posts(respond=true)
    @channel = Channel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    @last_post_id = 0
    @post = Post.new
  end

  def channel_params
    params.require(:channel).permit(:title, :text, :body)
  end

  def channel_redirect
    r = ChannelRedirect.from_id(params[:id])
    if r && r.respond_to?(:target_channel_id)
      redirect_to channel_path(r.target_channel_id)
    end
  end

end
