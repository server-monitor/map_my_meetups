class Venue < ApplicationRecord
  belongs_to :meetup_event

  validates_presence_of :latitude
  validates_presence_of :longitude
end
