class CleanupTables < ActiveRecord::Migration
  def change
    drop_table :channel_users
    drop_table :channel_visits
    drop_table :messages
    drop_table :stylesheets
    drop_table :uploads
  end
end
