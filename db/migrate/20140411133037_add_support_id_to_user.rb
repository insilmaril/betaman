class AddSupportIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :support_id, :text
  end
end
