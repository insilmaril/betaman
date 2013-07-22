class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.string :status
      t.integer :user_id
      t.integer :beta_id

      t.timestamps
    end
  end
end
