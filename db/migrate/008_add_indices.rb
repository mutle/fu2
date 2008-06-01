class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :users, :login
    add_index :users, :crypted_password
    add_index :users, :activation_code
    
    add_index :channels, :title
    add_index :channels, :permalink
    add_index :channels, :created_at
    
    add_index :posts, :channel_id
    add_index :posts, :user_id
    add_index :posts, :created_at
    
    add_index :channel_visits, :channel_id
    add_index :channel_visits, :user_id
    
  end

  def self.down
    remove_index :users, :login
    remove_index :users, :crypted_password
    remove_index :users, :activation_code
    
    remove_index :channels, :title
    remove_index :channels, :permalink
    remove_index :channels, :created_at
    
    remove_index :posts, :channel_id
    remove_index :posts, :user_id
    remove_index :posts, :created_at
    
    remove_index :channel_visits, :channel_id
    remove_index :channel_visits, :user_id
  end
end
