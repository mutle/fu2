class ChannelsController < ApplicationController
  
  before_filter :login_required
  
  def index
    if current_user && current_user.password_hash.blank?
      redirect_to password_user_path(:id => current_user.id) and return
    end
    @recent_channels = Channel.recent_channels(current_user, (params[:page] || 1).to_i)
  end
  
  def show
    if params[:id] == "all"
      @channels = Channel.all_channels(current_user, (params[:page] || 1).to_i)
      render :action => "all"
    else
      @channel = Channel.find(params[:id], :include => :posts)
      @channel.visit(current_user)
      @post = @channel.posts.new
      render
    end
  end
  
  def new
    @channel = Channel.new
  end
  
  def create
    @channel = Channel.create(params[:channel].merge(:user_id => current_user.id))
    
    redirect_to channel_path(@channel)
  end
  
  def search
    @query = params[:search].to_s
    if @query =~ /^title:(.*)$/
      @search = Channel.search($1, :per_page => 25, :page => (params[:page] || 1).to_i, :star => true)
    else
      @search = ThinkingSphinx.search(@query, :classes => [Channel, Post], :per_page => 25, :page => (params[:page] || 1).to_i, :star => true)
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => @search.map { |r| {:title => r.title, :display_title => r.excerpts.title, :id => r.id} } }
    end
  end
  
end
