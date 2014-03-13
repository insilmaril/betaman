class MoreCommentsToString < ActiveRecord::Migration
  def up
    change_column :groups, :comment, :text
    change_column :lists, :comment, :text
    change_column :users, :note, :text
    change_column :participations, :note, :text
  end

  def down
    change_column :groups, :comment, :string
    change_column :lists, :comment, :string
    change_column :users, :note, :string
    change_column :participations, :note, :string
  end
end
