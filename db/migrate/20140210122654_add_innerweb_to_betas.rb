class AddInnerwebToBetas < ActiveRecord::Migration
  def change
    add_column :betas, :novell_iw_user, :string
    add_column :betas, :novell_iw_pass, :string
  end
end
