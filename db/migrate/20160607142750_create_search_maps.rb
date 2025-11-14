class CreateSearchMaps < ActiveRecord::Migration[4.2]
  def change
    create_table :search_maps do |t|

      t.timestamps
    end
  end
end
