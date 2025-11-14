class AddTimeseriesToCollection < ActiveRecord::Migration[4.2]
  def change
    add_column :collections, :timeseries, :boolean
  end
end
