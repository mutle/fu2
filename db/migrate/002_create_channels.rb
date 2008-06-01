class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.string :title, :null => false
      t.integer :user_id, :null => false
      t.string :permalink, :null => false
      t.boolean :default_read, :null => false, :default => true
      t.boolean :default_write, :null => false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :channels
  end
end
