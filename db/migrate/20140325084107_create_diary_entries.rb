class CreateDiaryEntries < ActiveRecord::Migration
  def change
    create_table :diary_entries do |t|
      t.timestamps
      t.integer :user_id
      t.text    :text
      t.string  :event
    end
  end
end
