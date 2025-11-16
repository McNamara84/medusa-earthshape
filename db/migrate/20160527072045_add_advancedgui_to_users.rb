class AddAdvancedguiToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :advanced, :boolean
  end
end
