class CreateMeetupEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :meetup_events do |t|
      t.string :meetup_dot_com_id
      t.string :name
      t.decimal :time
      t.string :utc_offset
      t.string :link
      t.belongs_to :user, foreign_key: true
      t.string :venue_name

      t.timestamps
    end
  end
end
