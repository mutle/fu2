class CreateChannelRedirects < ActiveRecord::Migration
  def change
    create_table :channel_redirects do |t|
      t.integer :original_channel_id
      t.integer :target_channel_id

      t.timestamps null: false
    end

    add_index :channel_redirects, :original_channel_id
    add_index :channel_redirects, :target_channel_id
  end
end
