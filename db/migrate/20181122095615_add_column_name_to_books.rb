class AddColumnNameToBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :books, :name, :string
  end
end
