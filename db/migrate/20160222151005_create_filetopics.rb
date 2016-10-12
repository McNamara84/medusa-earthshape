class CreateFiletopics < ActiveRecord::Migration
  def change
    create_table :filetopics do |t|
      t.string :name

      t.timestamps
    end
  end
end
