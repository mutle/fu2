class PostsController < ApplicationController
  
  before_filter :login_required
  before_filter :load_channel

  respond_to :html, :json
  
  def create
    @post = @channel.posts.create(:body => params[:post][:body], :user_id => current_user.id)
    notification :post_create, @post
    
    respond_with @post do |f|
      f.html { redirect_to channel_path(@channel, :anchor => "post_#{@post.id}") }
      f.json { render :json => @post }
    end
  end
  
  def edit
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
  end
  
  def update
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
    @post.update_attributes(params[:post])
    notification :post_update, @post
    
    redirect_to channel_path(@channel, :anchor => "post_#{@post.id}")
  end
  
  def destroy
    @post = @channel.posts.find(params[:id].to_i)
    notification :post_destroy, @post
    @post.destroy if @post.user_id == current_user.id
    
    redirect_to channel_path(@channel)
  end
  
  private
  def load_channel
    @channel = Channel.find(params[:channel_id].to_i)
  end
  
end
