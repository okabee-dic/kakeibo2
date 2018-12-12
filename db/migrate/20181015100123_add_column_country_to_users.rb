class AddColumnCountryToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :country, :varchar
  end
end
