class CreatePreparations < ActiveRecord::Migration
  def change
    create_table :preparations do |t|
      t.string :info
      t.references :preparation_type, index: true
      t.references :stone, index: true

      t.timestamps
    end
  end
end
