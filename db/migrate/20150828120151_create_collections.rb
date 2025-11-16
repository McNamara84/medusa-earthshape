class CreateCollections < ActiveRecord::Migration[4.2]
  def change
    create_table :collections do |t|
      t.string :fieldname
      t.string :collector
      t.date :collection_start
      t.date :collection_end
      t.float :depth_min
      t.float :depth_max
      t.string :depth_unit
      t.text :depth_comment
      t.text :comment
      t.references :collectionmethod, index: true

      t.timestamps
    end
  end
end
