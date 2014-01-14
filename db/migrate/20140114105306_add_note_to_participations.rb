class AddNoteToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :note, :string
  end
end
