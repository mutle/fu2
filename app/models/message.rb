class Message < ActiveRecord::Base
  
  belongs_to :user
  
  def self.find_incoming_messages_from_user(who)
    find :conditions => [ 'reciever_id = ?', who.id ], :order => "time_sent DESC"
  end
  
  def self.find_outgoing_messages_from_user(who)
    find :conditions => [ 'sender_id = ?', who.id ], :order => "time_sent DESC"
  end
  
end
