class RenameDepthOfSample < ActiveRecord::Migration
  def change
	  rename_column :stones, :depth, :sampledepth
  end
end
