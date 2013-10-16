class AddBetaIdToList < ActiveRecord::Migration
  def change
    add_column :lists, :beta_id, :integer
  end
end
