class AddMarkdownToUsers < ActiveRecord::Migration
  def change
    add_column :users, :markdown, :boolean, :default => true
  end
end
