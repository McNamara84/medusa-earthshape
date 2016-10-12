class AddSiteinfoToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :slope_description, :string
    add_column :places, :landuse, :string
  end
end
