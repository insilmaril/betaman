class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string  :url
      t.date    :date
      t.string  :comment
      t.boolean :internal

      t.timestamps
    end

    create_table :urllinks do |t|
      t.integer :url_id
      t.integer :beta_id
      t.belongs_to :url
      t.belongs_to :beta

      t.timestamps
    end
  end
end
