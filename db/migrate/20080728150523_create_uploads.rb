class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.integer :user_id, :null => false
      t.string :file_id, :null => false, :default => ''
      t.string :file_name, :null => false, :default => ''
      t.string :file_ext, :null => false, :default => ''
      
      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
