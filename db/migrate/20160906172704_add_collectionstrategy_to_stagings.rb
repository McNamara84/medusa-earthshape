class AddCollectionstrategyToStagings < ActiveRecord::Migration[4.2]
  def change
    add_column :stagings, :collection_strategy, :string
  end
end
