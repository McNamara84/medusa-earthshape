class AddCollectionmethodRefToStone < ActiveRecord::Migration[4.2]
  def change
    add_reference :stones, :collectionmethod, index: true
  end
end
