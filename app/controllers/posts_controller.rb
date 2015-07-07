class PostsController < ApplicationController
  before_filter :login_required

  def edit
    @channel = Channel.find(params[:channel_id].to_i)
    @post = @channel.posts.find(params[:id].to_i)
    raise ActiveRecord::RecordNotFound unless @post.user_id == @current_user.id
  end

end
