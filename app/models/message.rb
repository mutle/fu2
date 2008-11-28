class Message < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :sender, :class_name => "User", :foreign_key => "user_id"
  
  validates_associated :sender, :user
  
  validates_presence_of :receiver_id
 
  after_save :update_user_message_counter

  
  def self.find_incoming_messages_from_user(who)
    find :all, :conditions => ['receiver_id = ?', who.id ], :order => "created_at DESC"
  end
  
  def self.find_outgoing_messages_from_user(who)
    find :all, :conditions => ['sender_id = ?', who.id ], :order => "created_at DESC"
  end
  
  # Beim speichern der MEssage subject und body in htmlspecialchars umwandeln mit beforefilter


  def update_user_message_counter
    User.find(:first, :conditions => ["display_name = ?", self.receiver_display_name]).update_message_counter
  end
  
  def receiver_name=(name)
    receiver = User.find(:first, :conditions => ["display_name = ?", name])
    self.receiver_display_name = receiver ? receiver.display_name : nil
    self.receiver_id = receiver ? receiver.id : nil
  end  
  
end
