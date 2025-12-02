# frozen_string_literal: true

# Fix typo in column name: place_topographic_positon -> place_topographic_position
class FixTopographicPositionTypo < ActiveRecord::Migration[8.1]
  def change
    rename_column :stagings, :place_topographic_positon, :place_topographic_position
  end
end
