class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :city
      t.string :zip
      t.string :country
      t.string :state
      t.string :phone

      t.timestamps
    end

    add_column :users, :address_id, :integer
    add_column :addresses, :user_id, :integer
  end
end
