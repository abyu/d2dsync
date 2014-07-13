class AddLinkedUserIdAndSequenceToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :linked_user_id, :string
    add_column :linked_accounts, :sequence, :int
  end
end
