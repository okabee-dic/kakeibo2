class DropTableSexes < ActiveRecord::Migration[5.1]
  def change
    drop_table :sexes
  end
end
