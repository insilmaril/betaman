class AddColumnToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :user_id, :integer
  end
end
