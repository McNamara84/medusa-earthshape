class CreateTopographicPositions < ActiveRecord::Migration
  def change
    create_table :topographic_positions do |t|
      t.string :name

      t.timestamps
    end
  end
end
