class CreateSearchMaps < ActiveRecord::Migration
  def change
    create_table :search_maps do |t|

      t.timestamps
    end
  end
end
