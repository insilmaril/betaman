class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :name
      t.date   :date
      t.string :comment

      t.timestamps
    end

    create_table :miles do |t|
      t.integer :milestone_id
      t.integer :beta_id
      t.belongs_to :milestone
      t.belongs_to :beta

      t.timestamps
    end
  end
end
