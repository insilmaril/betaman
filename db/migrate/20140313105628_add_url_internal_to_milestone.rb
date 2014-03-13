class AddUrlInternalToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :url, :string
  end
end
