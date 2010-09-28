class AddBlockUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :block_users, :text
  end

  def self.down
  end
end
