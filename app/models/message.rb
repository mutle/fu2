class Message < ActiveRecord::Base
  
  STATUS_UNREAD = 0
  STATUS_READ = 1
  STATUS_REPLIED = 2
  
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  
  # validates_associated :sender, :user
  
  validates_presence_of :user_id, :message => "not found."
  validates_presence_of :subject
 
  # after_save :update_user_message_counter
  # after_destroy :update_user_message_counter
  
  attr_reader :receiver_name

  
  def self.find_incoming_messages_from_user(who)
    find :all, :conditions => ['user_id = ?', who.id ], :order => "created_at DESC"
  end
  
  def self.find_outgoing_messages_from_user(who)
    find :all, :conditions => ['sender_id = ?', who.id ], :order => "created_at DESC"
  end
  
  def update_user_message_counter
    user.update_message_counter
  end
  
  def receiver_name=(name)
    @receiver = User.find_by_login(name) || User.find_by_display_name(name)
    @receiver_name = @receiver ? @receiver.login : name
    self.user_id = @receiver ? @receiver.id : nil
  end
  
  def quote_message=(message)
    self.body = "<blockquote>#{message.body}</blockquote>\n\n"
    self.subject = "Re: #{message.subject}"
  end
  
end
