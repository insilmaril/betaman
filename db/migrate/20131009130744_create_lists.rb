class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.string :comment
      t.string :pass
      t.string :server

      t.timestamps
    end
  end
end
