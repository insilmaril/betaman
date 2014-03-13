class MilestoneCommentsToString < ActiveRecord::Migration
  def up
    change_column :milestones, :comment, :text
    change_column :milestones, :comment_internal, :text
  end

  def down
    change_column :milestones, :comment, :string
    change_column :milestones, :comment_internal, :string
  end
end
