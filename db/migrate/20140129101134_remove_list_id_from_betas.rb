class RemoveListIdFromBetas < ActiveRecord::Migration
  def up
    remove_column :betas, :list_id
  end

  def down
    add_column :betas, :list_id, :integer
  end
end
