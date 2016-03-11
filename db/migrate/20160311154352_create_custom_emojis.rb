class CreateCustomEmojis < ActiveRecord::Migration
  def change
    create_table :custom_emojis do |t|
      t.string :url
      t.string :name
      t.string :aliases
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :custom_emojis, :user_id
    add_index :custom_emojis, :aliases
  end
end
