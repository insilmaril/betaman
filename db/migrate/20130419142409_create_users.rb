class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :email_idl
      t.string :company
      t.boolean :admin

      t.timestamps
    end
  end
end
