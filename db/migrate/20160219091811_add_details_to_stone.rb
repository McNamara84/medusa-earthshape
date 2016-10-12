class AddDetailsToStone < ActiveRecord::Migration
  def change
    add_column :stones, :depth, :float
    add_column :stones, :date, :date
  end
end
