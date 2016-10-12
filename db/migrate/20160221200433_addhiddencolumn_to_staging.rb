class AddhiddencolumnToStaging < ActiveRecord::Migration
  def change
    add_column :stagings, :hidden_column, :string
  end
end
