class AddFlagsToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :downloads_act, :bool
    add_column :participations, :support_req, :bool
    add_column :participations, :support_act, :bool
    add_column :participations, :list_act, :bool
  end
end
