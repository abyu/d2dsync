class AddGAuthToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :google_auth_token, :string
  end
end
