class CreateStylesheets < ActiveRecord::Migration
  def self.up
    create_table :stylesheets do |t|
      t.integer :user_id
      t.text :title
      t.text :code

      t.timestamps
    end
    
    add_index :stylesheets, :user_id
    
    add_column :users, :stylesheet_id, :integer, :null => false, :default => 0
  end

  def self.down
    drop_table :stylesheets
    
    remove_column :users, :stylesheet_id
    
    remove_index :stylesheets, :user_id
  end
end
