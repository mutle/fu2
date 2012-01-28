class Post < ActiveRecord::Base
  
  belongs_to :channel
  belongs_to :user

  scope :first_channel_post, proc { |c| includes(:user).where(:channel_id => c.id).order("created_at DESC").limit(1) }
  
  after_create :delete_channel_visits
  after_create :update_channel_last_post
  
  define_index do
    indexes body
    has channel(:default_read)
    where sanitize_sql(['default_read', true])
  end
  
  def delete_channel_visits
    channel.delete_visits
  end
  
  def update_channel_last_post
    channel.update_attribute(:last_post, created_at)
  end
  
  def can_read?(user)
    channel.can_read?(user)
  end
  
end
