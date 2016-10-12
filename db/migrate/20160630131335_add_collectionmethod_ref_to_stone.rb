class AddCollectionmethodRefToStone < ActiveRecord::Migration
  def change
    add_reference :stones, :collectionmethod, index: true
  end
end
