class AddWeatherConditonsToCollection < ActiveRecord::Migration[4.2]
  def change
	  rename_column :collections, :depth_comment, :weather_conditions
  end
end
