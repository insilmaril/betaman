class AddActorToDiaryEntries < ActiveRecord::Migration
  def change
    add_column :diary_entries, :actor_id, :integer
  end
end
