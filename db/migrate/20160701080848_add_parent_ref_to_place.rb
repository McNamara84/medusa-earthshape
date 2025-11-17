class AddParentRefToPlace < ActiveRecord::Migration[4.2]
  def change
    add_reference :places, :parent, index: true
  end
end
