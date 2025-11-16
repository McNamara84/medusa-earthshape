class AddhiddencolumnToStaging < ActiveRecord::Migration[4.2]
  def change
    add_column :stagings, :hidden_column, :string
  end
end
