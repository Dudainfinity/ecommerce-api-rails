class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string :sku, null: false
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
