class AddParticipationToBeta < ActiveRecord::Migration
  def change
    add_column :betas, :participation_id, :integer
  end
end
