class CreatePrets < ActiveRecord::Migration
  def change
    create_table :prets do |t|
      t.string :name
      t.point :latlon, :geographic => true
      t.string :phone_number
      t.string :seating
      t.boolean :has_toilets
      t.boolean :has_wheelchair_access
      t.boolean :has_wifi
      t.boolean :has_opened
      t.string :address
      t.text :directions
      t.integer :pret_number
      t.text :opening_hours
      t.timestamps
    end
  end
end
