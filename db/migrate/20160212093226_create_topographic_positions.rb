class CreateTopographicPositions < ActiveRecord::Migration[4.2]
  def change
    create_table :topographic_positions do |t|
      t.string :name

      t.timestamps
    end
  end
end
