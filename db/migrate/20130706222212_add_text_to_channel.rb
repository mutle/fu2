class AddTextToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :text, :text
  end
end
