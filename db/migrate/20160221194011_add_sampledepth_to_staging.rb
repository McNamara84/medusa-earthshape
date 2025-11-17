class AddSampledepthToStaging < ActiveRecord::Migration[4.2]
  def change
    add_column :stagings, :sample_depth, :float
  end
end
