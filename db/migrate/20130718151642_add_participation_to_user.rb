class AddParticipationToUser < ActiveRecord::Migration
  def change
    add_column :users, :participation_id, :integer
  end
end
