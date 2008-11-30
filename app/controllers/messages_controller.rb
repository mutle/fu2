class MessagesController < ApplicationController
  
  before_filter :login_required
  
  MSG_STATUS_UNREAD = 0
  MSG_STATUS_READ = 1
  MSG_STATUS_REPLIED = 2
  
  
  def index
    @incoming_messages = Message.find_incoming_messages_from_user(current_user)
    @active_menu = :inbox
  end
  
  def inbox
    index
    render :action => "index"
  end

  def sent
    @outgoing_messages = Message.find_outgoing_messages_from_user(current_user)
    @active_menu = :sent
  end
  
  def show
    @message = Message.find params[:id]
    if current_user.id == @message.receiver_id && @message.status == MSG_STATUS_UNREAD
      @message.status = MSG_STATUS_READ
      @message.save
    end
  end
  
  def new
    @message = Message.new
    @active_menu = :new
  end
  
  def create
    @message = Message.create(params[:message].merge({:sender_id => current_user.id, :sender_display_name => current_user.display_name}))
    @message.receiver_name = params[:receiver_name]

    if @message.save
      redirect_to message_path(@message)
    else
      render :action => "new"
    end
  end

end
