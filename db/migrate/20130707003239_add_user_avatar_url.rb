class AddUserAvatarUrl < ActiveRecord::Migration
  def change
    add_column :users, :avatar_url, :text
  end
end
