class ReactController < ApplicationController
  before_action :login_required
  before_action :channel_redirect, only: [:channel]
  before_action :channel_exists, only: [:channel]

  def index
    render "index"
  end

  def channel
    render "index"
  end

  private
  def channel_redirect
    r = ChannelRedirect.from_id(params[:id])
    if r && r.respond_to?(:target_channel_id)
      redirect_to channel_path(r.target_channel_id)
    end
  end

  def channel_exists
    Channel.find(params[:id])
  end
end
