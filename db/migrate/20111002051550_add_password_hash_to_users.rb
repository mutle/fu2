class AddPasswordHashToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_hash, :string
  end

  def self.down
  end
end
