class RenameLastPostToLastPostDate < ActiveRecord::Migration
  def change
    rename_column :channels, :last_post, :last_post_date
  end
end
