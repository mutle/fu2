class Message < ActiveRecord::Base
  
  belongs_to :user
  
  def self.find_incoming_messages_from_user(who)
    find :all, :conditions => ['reciever_id = ?', who.id ], :order => "created_at DESC"
  end
  
  def self.find_outgoing_messages_from_user(who)
    find :all, :conditions => ['sender_id = ?', who.id ], :order => "created_at DESC"
  end
  
  # Beim speichern der MEssage subject und body in htmlspecialchars umwandeln
  
  
end
