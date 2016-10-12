class CreateStonecontainerTypes < ActiveRecord::Migration
  def change
    create_table :stonecontainer_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
