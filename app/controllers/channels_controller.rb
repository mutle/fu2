class ChannelsController < ApplicationController
  
  before_filter :login_required
  
  def index
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
    @search = Ultrasphinx::Search.new(:query => @query, :per_page => 20, :page => (params[:page] || 1).to_i)
    @search.excerpt
    @correction = Ultrasphinx::Spell.correct(@search.query)
    
    respond_to do |format|
      format.html
      format.json { render :json => @search.results }
    end
  end
  
end
