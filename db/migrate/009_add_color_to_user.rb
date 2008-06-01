class AddColorToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :color, :string, :default => ""
  end

  def self.down
    remove_column :users, :color
  end
end
