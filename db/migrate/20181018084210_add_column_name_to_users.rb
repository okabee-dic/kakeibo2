class AddColumnNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :varchar
  end
end
