class MessagesController < ApplicationController
  
  before_filter :login_required
  
  MSG_STATUS_UNREAD = 0
  MSG_STATUS_READ = 1
  MSG_STATUS_REPLIED = 2
  
  
  def index
    @incoming_messages = Message.find_incoming_messages_from_user(current_user)
  end
  
  def inbox
    index
    render :action => "index"
  end

  def sent
    @outgoing_messages = Message.find_outgoing_messages_from_user(current_user)
  end
  
  def show
    @message = Message.find params[:id]
    if current_user.id == @message.reciever_id && @message.status == MSG_STATUS_UNREAD
      @message.status = MSG_STATUS_READ
      @message.save
      current_user.number_unread_messages = current_user.number_unread_messages - 1
      current_user.save
    end
  end
  
  def new
    @message = Message.new
  end
  
  def create
    
    reciever = User.find(:first, :conditions => ['display_name = ?', params[:reciever_name]])
    
    ### Richtige Railsway Fehlerbehandlung einbauen
    
    if reciever == nil
      redirect_to :action => "new"
    else
      missing_fields = {:sender_id => current_user.id, :sender_display_name => current_user.display_name, :reciever_id => reciever.id}
      @message = Message.create(params[:message].merge(missing_fields))
      
      reciever.number_unread_messages = reciever.number_unread_messages + 1
      reciever.save
      
      if @message.save
        redirect_to :action => "show", :id => @message.id
      else
        ### Eigentlich fehlemeldung + redirect zum messageeditor mit formular noch ausgefüllt
        redirect_to :action => "show", :id => @message.id
      end
    end

  end

end
