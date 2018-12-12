class CreateIncomes < ActiveRecord::Migration[5.1]
  def change
    create_table :incomes do |t|
      t.integer :store_id
      t.date :pay_date
      t.integer :price
      t.integer :book_id
      t.timestamps
    end
  end
end
