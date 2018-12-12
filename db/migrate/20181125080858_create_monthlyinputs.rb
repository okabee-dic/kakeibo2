class CreateMonthlyinputs < ActiveRecord::Migration[5.1]
  def change
    create_table :monthlyinputs do |t|
      t.integer :book_id
      t.integer :price
      t.integer :store_id
      t.integer :pay_date
      t.boolean :is_income, default: false
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
