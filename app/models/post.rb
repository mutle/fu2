class Post < ActiveRecord::Base
  
  belongs_to :channel
  belongs_to :user
  
  after_create :delete_channel_visits
  after_create :update_channel_last_post
  
  # is_indexed  :fields => ['created_at', 'body'],
  #             :include => [{:association_name => 'channel', :field => 'default_read'}],
  #             :conditions => ["default_read = true"]
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
