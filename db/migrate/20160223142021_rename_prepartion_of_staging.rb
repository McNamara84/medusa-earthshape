class RenamePrepartionOfStaging < ActiveRecord::Migration
  def change
	  rename_column :stagings, :treatment_prepraration2, :treatment_preparation2	  
  end
end
