class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :comment

      t.timestamps
    end

    create_table :memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.belongs_to :user
      t.belongs_to :group

      t.timestamps
    end
  end
end
