class RemoveGooleIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :goole_id, :string
  end
end
