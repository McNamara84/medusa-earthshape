class CreateLanduses < ActiveRecord::Migration
  def change
    create_table :landuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
