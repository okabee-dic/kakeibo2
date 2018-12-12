class ChangeColumnNameShownumberToNumbering < ActiveRecord::Migration[5.1]
  def change
    rename_column :stores, :shownumber, :numbering
  end
end
