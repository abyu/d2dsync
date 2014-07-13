class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|
      t.string :account_type
      t.string :access_token
      t.string :additional_params
      t.references :user, index: true

      t.timestamps
    end
  end
end
