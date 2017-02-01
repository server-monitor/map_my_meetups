class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.belongs_to :meetup_event, foreign_key: true
      t.integer :venue_id
      t.string :name
      t.decimal :latitude, precision: 21, scale: 16
      t.decimal :longitude, precision: 21, scale: 16
      t.boolean :repinned
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.integer :zip

      t.timestamps
    end
  end
end
