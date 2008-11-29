class Message < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :sender, :class_name => "User", :foreign_key => "user_id"
  
  validates_associated :sender, :user
  
  validates_presence_of :receiver_id, :message => "not found."
  validates_presence_of :subject
 
  #before_save :convert_html_special_chars_in_subject_and_body  #### NOCH MACHEN
 
  after_save :update_user_message_counter

  
  def self.find_incoming_messages_from_user(who)
    find :all, :conditions => ['receiver_id = ?', who.id ], :order => "created_at DESC"
  end
  
  def self.find_outgoing_messages_from_user(who)
    find :all, :conditions => ['sender_id = ?', who.id ], :order => "created_at DESC"
  end


  def update_user_message_counter
    User.find(:first, :conditions => ["display_name = ?", self.receiver_display_name]).update_message_counter
  end
  
  def receiver_name=(name)
    receiver = User.find(:first, :conditions => ["display_name = ?", name])
    self.receiver_display_name = receiver ? receiver.display_name : nil
    self.receiver_id = receiver ? receiver.id : nil
  end
  

  protected
    # before filter 
    def convert_html_special_chars_in_subject_and_body
      self.subject =  h(self.subject)
      self.message_body =  h(self.message_body)
    end
  
end
