class CreateVegetations < ActiveRecord::Migration[4.2]
  def change
    create_table :vegetations do |t|
      t.string :name

      t.timestamps
    end
  end
end
