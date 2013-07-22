class DropParticipations < ActiveRecord::Migration
  def up
    drop_table :participations
  end

  def down
    create_table :participations do |t|
      t.string  :status
      t.integer :user_id
      t.integer :beta_id
    end
  end
end
