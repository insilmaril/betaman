class DropPartIdsFromTables < ActiveRecord::Migration
  def up
    remove_column :users, :participation_id
    remove_column :betas, :participation_id
  end

  def down
    add_column :users, :participation_id, :integer
    add_column :betas, :participation_id, :integer
  end
end
