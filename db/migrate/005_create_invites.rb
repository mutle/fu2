class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.string :activation_code
      t.boolean :approved, :null => false, :default => false
      t.boolean :sent, :null => false, :default => false
      t.text :approved_users
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
