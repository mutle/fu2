class UpdateInvite < ActiveRecord::Migration[5.0]
  def change
    add_column :invites, :completed, :boolean, default: false

    drop_table :invite_approvals

    remove_column :users, :stylesheet_id
    remove_column :users, :number_unread_messages
    remove_column :users, :block_users
    remove_column :users, :color
    remove_column :users, :markdown
    remove_column :users, :crypted_password
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end
end
