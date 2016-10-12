class RemoveStagingsForNewCsv < ActiveRecord::Migration
  def change
  remove_column :stagings, :collection_collector
  remove_column :stagings, :collection_affiliation
  remove_column :stagings, :collection_start
  remove_column :stagings, :collection_end
  remove_column :stagings, :collection_depth_min
  remove_column :stagings, :collectin_depth_max
  remove_column :stagings, :place_weather
  
  add_column :stagings, :collection_weather, :string
  add_column :stagings, :collection_group, :string
  
  add_column :stagings, :place_is_parent, :string
  add_column :stagings, :place_parent, :string
  add_column :stagings, :place_group, :string
  add_column :stagings, :box_group, :string
  add_column :stagings, :sample_location, :string
  add_column :stagings, :sample_campaign, :string
  add_column :stagings, :sample_storageroom, :string
  add_column :stagings, :sample_group, :string
  add_column :stagings, :sample_collector, :string
  add_column :stagings, :sample_affiliation, :string

  
  end
end
