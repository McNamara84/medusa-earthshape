class AddAffiliationandprojectToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :affiliation, :string
    add_column :collections, :project, :string
  end
end
