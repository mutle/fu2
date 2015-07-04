class RenameLastPostToLastPostId < ActiveRecord::Migration
  def change
    rename_column :channels, :last_post, :last_post_id
  end
end
