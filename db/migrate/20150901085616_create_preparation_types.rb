class CreatePreparationTypes < ActiveRecord::Migration
  def change
    create_table :preparation_types do |t|
      t.string :name
      t.boolean :creates_siblings

      t.timestamps
    end
  end
end
