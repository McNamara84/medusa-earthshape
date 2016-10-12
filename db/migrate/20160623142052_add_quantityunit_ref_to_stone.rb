class AddQuantityunitRefToStone < ActiveRecord::Migration
  def change
    add_reference :stones, :quantityunit, index: true
  end
end
