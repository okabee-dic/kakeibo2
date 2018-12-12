class AddColumnPrefectureNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :prefecture_name, :varchar
  end
end
