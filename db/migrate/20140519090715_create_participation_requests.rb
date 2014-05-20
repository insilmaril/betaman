class CreateParticipationRequests < ActiveRecord::Migration
  def change
    create_table :participation_requests do |t|
      t.integer :user_id
      t.integer :participation_id
      t.belongs_to :participation
      t.belongs_to :user

      t.timestamps
    end
  end
end
