class RenameCollectionFieldname < ActiveRecord::Migration
  def change
	  rename_column :collections, :fieldname, :name
  end
end
