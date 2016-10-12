class CreateCollectionmethods < ActiveRecord::Migration
  def change
    create_table :collectionmethods do |t|
      t.string :name

      t.timestamps
    end
  end
end
