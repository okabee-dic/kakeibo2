class CreateGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :genres do |t|
      t.string :name
      t.boolean :income, default: false
      t.boolean :convinience, default: false
      t.boolean :supermarket, default: false
      t.boolean :eatout, default: false
      t.boolean :runningcost, default: false
      t.boolean :other, default: false
      t.boolean :unearned, default: false
      t.boolean :earning, default: false
      t.timestamps
    end
  end
end
