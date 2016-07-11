class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :name
      t.references :group, index: true, foreign_key: true
    end
  end
end
