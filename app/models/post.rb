class Post < ActiveRecord::Base
  
  belongs_to :channel
  belongs_to :user
  
  after_create :delete_channel_visits
  after_create :update_channel_last_post
  
  is_indexed  :fields => ['created_at', 'body'],
              :include => [{:association_name => 'channel', :field => 'default_read'}],
              :conditions => ["default_read = true"]
  
  def delete_channel_visits
    channel.delete_visits
  end
  
  def update_channel_last_post
    channel.update_attribute(:last_post, created_at)
  end
  
  def can_read?(user)
    if user.block_users && user.block_users.any? && !user.block_users.include?(self.user_id)
      false
    else
      channel.can_read?(user)
    end
  end
  
end
