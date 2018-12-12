class AddColumnsAddressToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :address, :varchar
    add_column :users, :building, :varchar
    add_column :users, :postcode, :varchar
    add_column :users, :prefecture_id, :integer
    add_column :users, :telephone, :varchar
    add_column :users, :sex, :integer
    add_column :users, :corporatename, :varchar
  end
end
