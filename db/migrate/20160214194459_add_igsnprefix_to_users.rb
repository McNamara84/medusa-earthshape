class AddIgsnprefixToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prefix, :string
  end
end
