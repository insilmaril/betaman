class RemoveListActFromParticipations < ActiveRecord::Migration
  def up
    remove_column :participations, :list_act
  end

  def down
    add_column :participations, :list_act, :string
  end
end
