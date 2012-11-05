class CreateFaves < ActiveRecord::Migration
  def up
    create_table :faves do |t|
      t.integer :user_id, :null => false
      t.integer :post_id, :null => false
      t.timestamps
    end
  end

  def down
  end
end
