class CreateAnalysisStones < ActiveRecord::Migration[4.2]
  def change
    create_table :analysis_stones do |t|
      t.references :stone, index: true
      t.references :analysis, index: true
    end
  end
end
