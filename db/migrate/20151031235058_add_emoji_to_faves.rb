class AddEmojiToFaves < ActiveRecord::Migration
  def change
    add_column :faves, :emoji, :string, default: "star"

    add_index :faves, :user_id
    add_index :faves, :post_id
    add_index :faves, :emoji
  end
end
