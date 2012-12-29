class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :user_id
      t.integer :post_id
      t.string :image_file
      t.string :filename

      t.timestamps
    end
  end
end
