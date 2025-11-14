class AddSamplingstrategyToCollection < ActiveRecord::Migration[4.2]
  def change
    add_column :collections, :samplingstrategy, :string
  end
end
