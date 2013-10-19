class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :reference_notification_id
      t.string :notification_type
      t.string :created_by_name
      t.integer :created_by_id
      t.integer :channel_id
      t.integer :post_id
      t.text :message
      t.text :metadata
      t.boolean :read, :default => false
      t.boolean :deleted, :default => false

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, :reference_notification_id
    add_index :notifications, :notification_type
    add_index :notifications, :created_by_id
    add_index :notifications, :channel_id
    add_index :notifications, :post_id
    add_index :notifications, :read
    add_index :notifications, :deleted
  end
end
