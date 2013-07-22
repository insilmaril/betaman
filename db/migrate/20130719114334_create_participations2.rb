class CreateParticipations2 < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.string :status
      t.integer :user_id
      t.integer :beta_id
      t.belongs_to :beta
      t.belongs_to :user

      t.timestamps
    end
  end
end
