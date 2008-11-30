class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :user_id,      :integer
      t.column :sender_id,    :integer
      t.column :status,       :integer, :default => 0
      t.column :subject,      :string
      t.column :body,         :text

      t.timestamps
    end
    
    add_column :users, :number_unread_messages, :integer, :default => 0
    User.all.each { |u| u.update_attribute(:number_unread_messages, 0) }
  end

  def self.down
    drop_table :messages
    
    remove_column :users, :number_unread_messages
  end
end
