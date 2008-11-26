class Messages::MessagesController < ApplicationController
  
  before_filter :login_required
  
  def index
    @incoming_messages = Message.find_incoming_messages_from_user(current_user)
  end
end
