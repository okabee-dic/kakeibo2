class AddColumnAllowShowToBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :books, :allow_show, :boolean, default: false, null: false
  end
end
