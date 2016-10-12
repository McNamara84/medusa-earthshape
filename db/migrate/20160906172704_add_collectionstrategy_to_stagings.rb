class AddCollectionstrategyToStagings < ActiveRecord::Migration
  def change
    add_column :stagings, :collection_strategy, :string
  end
end
