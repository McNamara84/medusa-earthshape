class AddSiteinfoToPlaces < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :slope_description, :string
    add_column :places, :landuse, :string
  end
end
