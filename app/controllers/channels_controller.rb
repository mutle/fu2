class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper

  layout :default_layout

  before_filter :login_required

  respond_to :html, :json

  def index(respond=true)
    @column_width = 12
    @page = (params[:page] || 1).to_i
    @recently_active = Channel.recently_active(current_user)
    @recent_channels = Channel.recent_channels(current_user, @page)
    @recent_channels.each { |c| c.current_user = current_user }
    @recent_posts = Channel.recent_posts(@recent_channels)
    @action = 'channels'
    if respond
      respond_with @recent_channels
    end
  end

  def activity(respond=true)
    @recently_active = Channel.recently_active(current_user)
    @recent_posts = Channel.recent_posts(@recently_active[:channels])
    @action = 'activity'
    if respond
      respond_with @recently_active
    end
  end

  def live
    if Post.most_recent.first.id > params[:last_id].to_i
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
    @letter = params[:letter]
    if @letter.blank?
      @channels = Channel.all_channels(current_user, (params[:page] || 1).to_i)
    else
      @channels = Channel.with_letter(@letter)
    end
    render "all"
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.create(channel_params.merge(:site_id => @site.id, :user_id => current_user.id, :markdown => current_user.markdown?))

    respond_with @channel do |f|
      f.html { redirect_to channel_path(@channel) }
      f.json { render :json => @channel }
    end
  end

  def update
    @channel = Channel.find params[:id]
    channel = params[:channel]
    @channel.text = channel[:text]
    @channel.title = channel[:title]
    @channel.updated_by = current_user.id
    @channel.save
    redirect_to channel_path(@channel)
  end

  def search
    @query = params[:search].to_s
    page = (params[:page] || 1).to_i
    if @query =~ /^title:(.*)$/
      @query = $1
      @search = Channel.search_channels(@query, page)
      @results = true
    elsif !@query.blank?
      @search = Channel.search_channels_and_posts(@query, page)
      @results = true
    else
      @results = false
    end
    @action = 'search'

    respond_to do |format|
      format.html
      format.json { render :json => @search.map { |r| {:title => r.title, :display_title => highlight_results(r.title, @query), :id => r.id} } }
    end
  end

  def visit
    @channel = Channel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    render json: {last_read: @last_read_id}
  end

  private
  def posts(respond=true)
    @channel = Channel.find(params[:id])
    @last_read_id = @channel.visit(current_user)
    @last_post_id = 0
    @post = Post.new
    @posts = @channel.posts.includes(:user, :faves).load
    @last_update = (@posts.map(&:created_at) + @posts.map(&:updated_at)).map(&:utc).max.to_i
    if respond
      respond_with @posts
    end
  end

  def channel_params
    params.require(:channel).permit(:title, :text, :body)
  end

end
