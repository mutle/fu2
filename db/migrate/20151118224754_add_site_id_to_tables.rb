class AddSiteIdToTables < ActiveRecord::Migration
  def change
    add_column :channels, :site_id, :integer, default: 1
    add_index :channels, :site_id
    add_column :channel_redirects, :site_id, :integer, default: 1
    add_index :channel_redirects, :site_id
    add_column :events, :site_id, :integer, default: 1
    add_index :events, :site_id
    add_column :faves, :site_id, :integer, default: 1
    add_index :faves, :site_id
    add_column :images, :site_id, :integer, default: 1
    add_index :images, :site_id
    add_column :notifications, :site_id, :integer, default: 1
    add_index :notifications, :site_id
    add_column :invites, :site_id, :integer, default: 1
    add_index :invites, :site_id
    add_column :key_values, :site_id, :integer, default: 1
    add_index :key_values, :site_id
    add_column :posts, :site_id, :integer, default: 1
    add_index :posts, :site_id
  end
end
