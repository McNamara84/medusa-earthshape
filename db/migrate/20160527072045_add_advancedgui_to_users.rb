class AddAdvancedguiToUsers < ActiveRecord::Migration
  def change
    add_column :users, :advanced, :boolean
  end
end
