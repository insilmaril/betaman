class AddCommentInternalToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :comment_internal, :string
  end
end
