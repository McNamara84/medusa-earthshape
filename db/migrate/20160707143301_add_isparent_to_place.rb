class AddIsparentToPlace < ActiveRecord::Migration
  def change
    add_column :places, :is_parent, :boolean
  end
end
