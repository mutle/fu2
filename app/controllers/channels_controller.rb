class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper
  
  layout :default_layout
  # layout 'application'

  before_filter :login_required

  respond_to :html, :json
  
  def index
    if current_user && current_user.password_hash.blank?
      redirect_to password_user_path(:id => current_user.id) and return
    end
    @recent_channels = Channel.recent_channels(current_user, (params[:page] || 1).to_i)
    @recent_channels.each { |c| c.current_user = current_user }
    respond_with @recent_channels
  end

  def live
    render :layout => "nextgen"
  end
  
  def show
    if params[:id] == "all"
      all
    else
      posts(false)
      respond_with @channel
    end
  end

  def posts(respond=true)
    @channel = Channel.find(params[:id], :include => :posts)
    @channel.visit(current_user)
    @post = Post.new
    if respond
      respond_with @channel.posts.all(:include => :user)
    end
  end

  def all
    @channels = Channel.all_channels(current_user, (params[:page] || 1).to_i)
    render "all"
  end
  
  def new
    @channel = Channel.new
  end
  
  def create
    @channel = Channel.create(params[:channel].merge(:user_id => current_user.id, :markdown => current_user.markdown?))
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
    p @search

    respond_to do |format|
      format.html
      format.json { render :json => @search.map { |r| {:title => r.title, :display_title => highlight_results(r.title, @query), :id => r.id} } }
    end
  end

  def desktop
    cookies['desktop'] = cookies['desktop'] == "true" ? "false" : "true"
    redirect_to request.referer
  end
  
end
