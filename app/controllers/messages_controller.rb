class MessagesController < ApplicationController
  
  before_filter :login_required
  
  
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
    if current_user.id == @message.user_id && @message.status == Message::STATUS_UNREAD
      @message.status = Message::STATUS_READ
      @message.save
    end
  end
  
  def new
    @message = Message.new(:receiver_name => params[:receiver_name] || '')
    @active_menu = :new
  end
  
  def create
    @message = Message.new(params[:message].merge({:sender_id => current_user.id}))

    if @message.save
      redirect_to message_path(@message)
    else
      puts @message.inspect
      render :action => "new"
    end
  end

end
