class CreateStagings < ActiveRecord::Migration[4.2]
  def change
    create_table :stagings do |t|
      t.string :collection_name
      t.string :collection_project
      t.string :collection_collector
      t.string :collection_affiliation
      t.boolean :collection_timeseries
      t.date :collection_start
      t.date :collection_end
      t.float :collection_depth_min
      t.float :collectin_depth_max
      t.text :collection_comment
      t.string :place_name
      t.string :place_latitude
      t.string :place_longitude
      t.float :place_elevation
      t.string :place_topographic_position
      t.string :place_slopedescription
      t.string :place_aspect
      t.string :place_vegetation
      t.string :place_landuse
      t.string :place_description
      t.text :place_weather
      t.string :place_lightsituation
      t.string :box_name
      t.string :box_parent
      t.string :box_type
      t.string :sample_name
      t.string :sample_igsn
      t.string :sample_labname
      t.date :sample_date
      t.string :sample_collectionmethod
      t.text :sample_comment
      t.string :sample_parent
      t.string :sample_material
      t.string :sample_classification
      t.string :sample_container
      t.float :sample_quantityinitial
      t.string :sample_unit
      t.float :sample_quantity
      t.string :treatment_monitor1
      t.string :treatment_monitor2
      t.string :treatment_monitor3
      t.string :treatment_preparation1
      t.string :treatment_prepraration2
      t.string :treatment_preparation3
      t.string :treatment_strategy
      t.string :treatment_analyticalmethod
      t.text :treatment_comment

      t.timestamps
    end
  end
end
