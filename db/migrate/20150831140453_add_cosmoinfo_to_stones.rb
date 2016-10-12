class AddCosmoinfoToStones < ActiveRecord::Migration
  def change
    add_column :stones, :quantity_initial, :float
    add_column :stones, :labname, :string
    add_column :stones, :igsn, :string
    add_reference :stones, :collection, index: true
    add_reference :stones, :stonecontainer_type, index: true
  end
end
