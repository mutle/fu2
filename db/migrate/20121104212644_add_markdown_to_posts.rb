class AddMarkdownToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :markdown, :boolean, :default => false
  end
end
