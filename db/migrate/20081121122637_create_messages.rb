class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :sender_id,                :integer
      t.column :sender_display_name,      :string
      t.column :reciever_id,              :integer
      t.column :status,                   :integer
      t.column :time_sent,                :datetime
      t.column :subject,                  :string
      t.column :message_body,             :text

      t.timestamps
    end

    add_column "users", :number_unread_messages, :integer, :default => 0
    
  end

  def self.down
    drop_table :messages
    
    remove_column "users", :number_unread_messages
  end
end
