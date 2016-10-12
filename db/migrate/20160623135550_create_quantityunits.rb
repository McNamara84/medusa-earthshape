class CreateQuantityunits < ActiveRecord::Migration
  def change
    create_table :quantityunits do |t|
      t.string :name

      t.timestamps
    end
  end
end
