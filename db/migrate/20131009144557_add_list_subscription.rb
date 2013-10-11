class AddListSubscription < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :list_id
      t.belongs_to :user
      t.belongs_to :list

      t.timestamps
    end

    #add_column :users, :subscription_id, :integer
    #add_column :lists, :subscription_id, :integer
  end
end
