class AddStatusToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :active, :bool, default: true
  end
end
