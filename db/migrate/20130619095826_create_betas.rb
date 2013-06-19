class CreateBetas < ActiveRecord::Migration
  def change
    create_table :betas do |t|
      t.string :name
      t.date :begin
      t.date :end

      t.timestamps
    end
  end
end
