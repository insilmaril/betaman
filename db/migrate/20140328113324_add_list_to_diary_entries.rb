class AddListToDiaryEntries < ActiveRecord::Migration
  def change
    add_column :diary_entries, :list_id, :integer
  end
end
