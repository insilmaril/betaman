class AddEloginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :elogin, :string
  end
end
