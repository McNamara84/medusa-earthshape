class AddParentRefToPlace < ActiveRecord::Migration
  def change
    add_reference :places, :parent, index: true
  end
end
