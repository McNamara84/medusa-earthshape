class AddParentinfoToPreparationTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :preparation_types, :full_name, :string
    add_column :preparation_types, :description, :text
    add_column :preparation_types, :parent_id, :integer
  end
end
