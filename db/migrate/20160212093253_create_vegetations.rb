class CreateVegetations < ActiveRecord::Migration
  def change
    create_table :vegetations do |t|
      t.string :name

      t.timestamps
    end
  end
end
