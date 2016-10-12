class AddSamplingstrategyToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :samplingstrategy, :string
  end
end
