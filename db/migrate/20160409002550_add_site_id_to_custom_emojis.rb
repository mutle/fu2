class AddSiteIdToCustomEmojis < ActiveRecord::Migration
  def change
    add_column :custom_emojis, :site_id, :integer, default: 1
    add_index :custom_emojis, :site_id
  end
end
