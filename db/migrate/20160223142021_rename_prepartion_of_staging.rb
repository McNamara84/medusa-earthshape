class RenamePrepartionOfStaging < ActiveRecord::Migration[4.2]
  def change
	  rename_column :stagings, :treatment_prepraration2, :treatment_preparation2	  
  end
end
