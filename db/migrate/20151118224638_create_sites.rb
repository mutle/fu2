class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :domain
      t.string :path
      t.integer :user_id

      t.timestamps
    end

    add_index :sites, :domain
    add_index :sites, :path
    add_index :sites, :user_id
  end
end
