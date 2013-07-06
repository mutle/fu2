class AddTextToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :text, :text
    add_column :channels, :updated_by, :integer
  end
end
