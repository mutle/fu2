class ChannelsController < ApplicationController
  include  ActionView::Helpers::TextHelper

  before_filter :login_required
  before_filter :channel_redirect, only: [:show]

  def index
    empty_response
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
      Channel.find(params[:id])
      empty_response
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
    empty_response
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
    # @last_read_id = @channel.visit(current_user)
    @last_post_id = 0
    @post = Post.new
  end

  def channel_redirect
    r = ChannelRedirect.from_id(params[:id])
    if r && r.respond_to?(:target_channel_id)
      redirect_to channel_path(r.target_channel_id)
    end
  end

end
