class RemoveStatusFromParticipation < ActiveRecord::Migration
  def up
    remove_column :participations, :status
  end

  def down
    add_column :participations, :status, :string
  end
end
