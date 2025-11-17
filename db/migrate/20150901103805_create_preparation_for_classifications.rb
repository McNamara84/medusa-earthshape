class CreatePreparationForClassifications < ActiveRecord::Migration[4.2]
  def change
    create_table :preparation_for_classifications do |t|
      t.references :classification, index: true, null: false
      t.references :preparation_type, index: true, null: false

      t.timestamps
    end
  end
end
