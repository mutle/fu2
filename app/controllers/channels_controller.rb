class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper

  before_filter :login_required

  respond_to :html, :json

  def index(respond=true)
    @column_width = 12
    @page = (params[:page] || 1).to_i
    @view = Views::ChannelList.new({
      current_user: current_user,
      site: @site,
      page: @page
    })
    @action = 'channels'
    @view.finalize
    if respond
      respond_with @view.recent_channels
    end
  end

  def live
    if sitePost.most_recent.first.id > params[:last_id].to_i
      index(false)
      render :action => "index", :layout => false
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
    @column_width = 12
    @view = Views::AllChannels.new({
      current_user: current_user,
      page: (params[:page] || 1).to_i,
      letter: params[:letter],
      site: @site
    })
    @view.finalize
    render "all"
  end

  def new
    @channel = siteChannel.new
  end

  def create
    @channel = Channel.create(channel_params.merge(:site_id => @site.id, :user_id => current_user.id, :markdown => current_user.markdown?))

    respond_with @channel do |f|
      f.html { redirect_to channel_path(@channel) }
      f.json { render :json => @channel }
    end
  end

  def update
    @channel = siteChannel.find params[:id]
    channel = params[:channel]
    @channel.text = channel[:text]
    @channel.rename(channel[:title], @current_user)
    @channel.updated_by = current_user.id
    @channel.save
    redirect_to channel_path(@channel)
  end

  def visit
    @channel = siteChannel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    render json: {last_read: @last_read_id}
  end

  def merge
  end

  def do_merge
  end

  private
  def posts(respond=true)
    @channel = siteChannel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    @last_post_id = 0
    @post = Post.new
    @view = Views::ChannelPosts.new({
      current_user: current_user,
      channel: @channel,
      last_read_id: @last_read_id
    })
    @view.finalize
    if respond
      respond_with @view.posts
    end
  end

  def channel_params
    params.require(:channel).permit(:title, :text, :body)
  end

end
