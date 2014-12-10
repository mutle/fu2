  class AddSiteIdToTables < ActiveRecord::Migration
  def change
    add_column :channels, :site_id, :integer, default: 1
    add_index :channels, :site_id
    add_column :faves, :site_id, :integer, default: 1
    add_index :faves, :site_id
    add_column :images, :site_id, :integer, default: 1
    add_index :images, :site_id
    add_column :notifications, :site_id, :integer, default: 1
    add_index :notifications, :site_id
    add_column :posts, :site_id, :integer, default: 1
    add_index :posts, :site_id
    add_column :users, :site_id, :integer, default: 1
    add_index :users, :site_id
  end
end
