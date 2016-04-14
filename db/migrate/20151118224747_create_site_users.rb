class CreateSiteUsers < ActiveRecord::Migration
  def change
    create_table :site_users do |t|
      t.integer :site_id
      t.integer :user_id
      t.string :role
    end

    add_index :site_users, :site_id
    add_index :site_users, :user_id
  end
end
