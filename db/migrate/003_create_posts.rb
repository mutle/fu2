class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :channel_id, :null => false
      t.integer :user_id, :null => false
      t.text :body, :null => false, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
