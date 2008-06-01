class CreateChannelUsers < ActiveRecord::Migration
  def self.up
    create_table :channel_users do |t|
      t.integer :channel_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :priv_read, :null => false, :default => true
      t.boolean :priv_write, :null => false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :channel_users
  end
end
