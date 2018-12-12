class CreateStores < ActiveRecord::Migration[5.1]
  def change
    create_table :stores do |t|
      t.integer :book_id
      t.string :name
      t.integer :genre_id
      t.integer :numbering
      t.boolean :is_income, defult: false
      t.timestamps
    end
  end
end
