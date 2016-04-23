class CreateChannelTags < ActiveRecord::Migration
  def change
    create_table :channel_tags do |t|
      t.integer :site_id
      t.integer :channel_id
      t.integer :post_id
      t.integer :user_id
      t.string :tag

      t.timestamps null: false
    end

    add_index :channel_tags, :site_id
    add_index :channel_tags, :channel_id
    add_index :channel_tags, :post_id
    add_index :channel_tags, :user_id
    add_index :channel_tags, :tag
    add_index :channel_tags, :created_at
  end
end
