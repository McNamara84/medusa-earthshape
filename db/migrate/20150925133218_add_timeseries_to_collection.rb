class AddTimeseriesToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :timeseries, :boolean
  end
end
