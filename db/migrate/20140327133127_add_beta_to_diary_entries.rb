class AddBetaToDiaryEntries < ActiveRecord::Migration
  def change
    add_column :diary_entries, :beta_id, :integer
  end
end
