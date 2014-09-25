class AddDownloadLocationToBeta < ActiveRecord::Migration
  def change
    add_column :betas, :downloadLocationExt, :string
    add_column :betas, :downloadLocationInt, :string
  end
end
