class ChangeColumnNameShownumberToNumbering < ActiveRecord::Migration[5.1]
  def change
    # 20181222
    # comment out to migration
    # because of no need to rename
    #rename_column :stores, :shownumber, :numbering
  end
end
