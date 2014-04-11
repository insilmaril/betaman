class AddSupportContactToUser < ActiveRecord::Migration
  def change
    add_column :users, :support_contact, :text
  end
end
