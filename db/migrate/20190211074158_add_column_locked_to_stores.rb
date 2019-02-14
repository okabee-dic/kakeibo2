class AddColumnLockedToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :locked, :boolean, default: false
  end
end
