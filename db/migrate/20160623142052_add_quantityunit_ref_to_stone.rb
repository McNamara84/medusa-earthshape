class AddQuantityunitRefToStone < ActiveRecord::Migration[4.2]
  def change
    add_reference :stones, :quantityunit, index: true
  end
end
