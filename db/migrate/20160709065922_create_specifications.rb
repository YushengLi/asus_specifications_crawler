class CreateSpecifications < ActiveRecord::Migration
  def change
    create_table :specifications do |t|
      t.string :name
      t.text :operating_system
      t.text :optical_device
      t.text :audio
      t.text :software
      t.text :source_url
      t.references :series, index: true, foreign_key: true
    end
  end
end
