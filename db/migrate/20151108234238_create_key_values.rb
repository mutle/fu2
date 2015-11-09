class CreateKeyValues < ActiveRecord::Migration
  def change
    create_table :key_values do |t|
      t.string :key
      t.text :value
      t.integer :post_id, default: 0

      t.timestamps null: false
    end

    add_index :key_values, :key
    add_index :key_values, :post_id
  end
end
