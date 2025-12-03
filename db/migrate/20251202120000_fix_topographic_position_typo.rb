# frozen_string_literal: true

# Fix typo in column name: place_topographic_positon -> place_topographic_position
class FixTopographicPositionTypo < ActiveRecord::Migration[8.1]
  def change
    # Only rename if the typo column exists (skip on fresh databases where schema already has correct name)
    if column_exists?(:stagings, :place_topographic_positon)
      rename_column :stagings, :place_topographic_positon, :place_topographic_position
    end
  end
end
