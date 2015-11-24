class Api::ChannelsController < Api::ApiController

  def index
    page = (params[:page] || 1).to_i
    @view = Views::ChannelList.new({
      current_user: current_user,
      page: page,
      per_page: 50,
      last_update_date: params[:last_update] ? Time.at(params[:last_update].to_i) : nil,
      query: params[:query]
    })
    @view.finalize
  end

  def create
    @channel = Channel.create(channel_params.merge(user_id: current_user.id, markdown: true))
    @channel.visit(current_user)
    if !@channel.valid?
      render json: {errors: @channel.errors}
    else
      render "show"
    end
  end

  def update
    @channel = Channel.find params[:id]
    channel = params[:channel]
    @channel.change_text(channel[:text], @current_user)
    @channel.rename(channel[:title], @current_user)
    @channel.updated_by = current_user.id
    @channel.save
    render "show"
  end

  private

  def channel_params
    params.require(:channel).permit(:title, :text, :body)
  end

end
