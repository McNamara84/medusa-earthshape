class CreateCollectors < ActiveRecord::Migration
  def change
    create_table :collectors do |t|
      t.string :name
      t.string :affiliation
      t.references :stone, index: true

      t.timestamps
    end
  end
end
