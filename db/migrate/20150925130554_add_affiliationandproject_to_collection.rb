class AddAffiliationandprojectToCollection < ActiveRecord::Migration[4.2]
  def change
    add_column :collections, :affiliation, :string
    add_column :collections, :project, :string
  end
end
