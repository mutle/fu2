class SetChannelUpdateAt < ActiveRecord::Migration
  def self.up
    add_column :channels, :last_post, :datetime
    
    Channel.find(:all).each do |channel|
      p = channel.posts.last
      channel.update_attribute(:last_post, p.created_at) if p
    end
  end

  def self.down
    remove_column :channels, :last_post
  end
end
