class AddWeatherConditonsToCollection < ActiveRecord::Migration
  def change
	  rename_column :collections, :depth_comment, :weather_conditions
  end
end
