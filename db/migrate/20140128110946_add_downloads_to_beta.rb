class AddDownloadsToBeta < ActiveRecord::Migration
  def change
    add_column :betas, :alias, :string
    add_column :betas, :novell_id, :string
    add_column :betas, :novell_user, :string
    add_column :betas, :novell_pass, :string
  end
end
