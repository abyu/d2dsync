class RemoveGoogleAuthTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :google_auth_token, :string
  end
end
