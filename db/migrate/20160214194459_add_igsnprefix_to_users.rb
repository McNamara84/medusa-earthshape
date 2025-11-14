class AddIgsnprefixToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :prefix, :string
  end
end
