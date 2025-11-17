class CreateCollectors < ActiveRecord::Migration[4.2]
  def change
    create_table :collectors do |t|
      t.string :name
      t.string :affiliation
      t.references :stone, index: true

      t.timestamps
    end
  end
end
