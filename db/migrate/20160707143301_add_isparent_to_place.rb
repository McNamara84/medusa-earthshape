class AddIsparentToPlace < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :is_parent, :boolean
  end
end
