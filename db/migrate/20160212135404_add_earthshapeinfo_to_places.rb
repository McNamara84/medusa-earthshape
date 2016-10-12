class AddEarthshapeinfoToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :aspect, :string
    add_reference :places, :vegetation, index: true
    add_reference :places, :landuse, index: true
    add_reference :places, :topographic_position, index: true
    add_column :places, :lightsituation, :string
  end
end
