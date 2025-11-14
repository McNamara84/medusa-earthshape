class AddDetailsToStone < ActiveRecord::Migration[4.2]
  def change
    add_column :stones, :depth, :float
    add_column :stones, :date, :date
  end
end
