class AddListIdToBeta < ActiveRecord::Migration
  def change
    add_column :betas, :list_id, :integer
  end
end
