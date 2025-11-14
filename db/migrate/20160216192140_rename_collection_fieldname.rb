class RenameCollectionFieldname < ActiveRecord::Migration[4.2]
  def change
	  rename_column :collections, :fieldname, :name
  end
end
