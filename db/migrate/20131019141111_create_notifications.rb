class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :reference_notification_id
      t.string :notification_type
      t.string :created_by
      t.integer :created_by_id
      t.text :message
      t.text :metadata
      t.boolean :read
      t.boolean :deleted

      t.timestamps
    end
  end
end
