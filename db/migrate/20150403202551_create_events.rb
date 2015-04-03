class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :channel_id
      t.integer :user_id
      t.string :event
      t.text :data
      t.text :message

      t.timestamps null: false
    end

    add_index :events, :channel_id
    add_index :events, :user_id
    add_index :events, :event
  end
end
