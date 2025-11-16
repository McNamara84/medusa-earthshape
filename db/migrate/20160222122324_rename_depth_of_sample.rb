class RenameDepthOfSample < ActiveRecord::Migration[4.2]
  def change
	  rename_column :stones, :depth, :sampledepth
  end
end
