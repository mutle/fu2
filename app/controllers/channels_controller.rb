class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper

  layout :default_layout

  before_filter :login_required

  respond_to :html, :json

  def index(respond=true)
    @column_width = 12
    @page = (params[:page] || 1).to_i
    @recent_channels = Channel.recent_channels(current_user, @page)
    @recent_channels.each { |c| c.current_user = current_user }
    if respond
      respond_with @recent_channels
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
    @channel = Channel.create(channel_params.merge(:user_id => current_user.id, :markdown => current_user.markdown?))
    notification :channel_create, @channel
    increment_metric "posts.all"
    increment_metric "posts.user.#{current_user.id}"
    increment_metric "channels.all"
    increment_metric "channels.id.#{@channel.id}.posts"
    increment_metric "channels.user.#{current_user.id}"

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
    else
      @search = Channel.search_channels_and_posts(@query, page)
      # @search = ThinkingSphinx.search(@query, :classes => [Channel, Post], :per_page => 25, :page => (params[:page] || 1).to_i, :star => true)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @search.map { |r| {:title => r.title, :display_title => highlight_results(r.title, @query), :id => r.id} } }
    end
  end

  def desktop
    cookies['desktop'] = cookies['desktop'] == "true" ? "false" : "true"
    redirect_to request.referer
  end

  private
  def posts(respond=true)
    @channel = Channel.find(params[:id], :include => :posts)
    @last_read_id = @channel.visit(current_user)
    @last_post_id = 0
    @post = Post.new
    if respond
      respond_with @channel.posts.all(:include => :user)
    end
  end

  def channel_params
    params.require(:channel).permit(:title, :text, :body)
  end

end
