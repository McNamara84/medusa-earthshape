class CreateCollectionmethods < ActiveRecord::Migration[4.2]
  def change
    create_table :collectionmethods do |t|
      t.string :name

      t.timestamps
    end
  end
end
