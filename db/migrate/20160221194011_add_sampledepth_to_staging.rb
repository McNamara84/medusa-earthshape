class AddSampledepthToStaging < ActiveRecord::Migration
  def change
    add_column :stagings, :sample_depth, :float
  end
end
