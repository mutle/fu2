class Invite < ActiveRecord::Base
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  
  before_create :make_activation_code
  after_save :send_invite
  
  belongs_to :user
  
  
  def send_invite
    if !sent? and can_send?
      UserMailer.deliver_invite(self)
      update_attributes(:sent => true, :approved => true)
    end
  end
  
  def can_send?
    true
  end
  
  private
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
end
