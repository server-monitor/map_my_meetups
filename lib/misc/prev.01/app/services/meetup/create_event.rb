
require_relative './base'

module Meetup
  class CreateEvent
    include Meetup::Base

    def perform(event_data, user_id)
      param_for_venue_model = param_for_venue_model_get event_data.venue
      return self if error_in? param_for_venue_model

      venue = venue_get param_for_venue_model.data

      param_for_meetup_event_model = param_for_meetup_event_model_get(
        event_data.without_venue
      )

      return if error_in? param_for_meetup_event_model

      meetup_event = meetup_event_create(
        param_for_meetup_event_model, venue: venue, user_id: user_id
      )
      return meetup_event
    end

    private

    def param_for_venue_model_get(venue)
      @param_for_venue_model ||= Meetup::ConvertAPIDataToParamFor::
                                         VenueModel.new.perform(venue)
    end

    def venue_get(venue_data)
      # venue = Venue.new(param_for_venue_model.data)
      # Not saved because it will complain that a meetup_event has to exists.
      # (Because venue belongs_to :meetup_event)
      # This will be saved when the meetup_event is saved.
      # venue.save
      # return if errors? venue

      @venue ||= ::Venue.new(venue_data)
    end

    def param_for_meetup_event_model_get(without_venue)
      @param_for_meetup_event_model ||= Meetup::ConvertAPIDataToParamFor::
                                                MeetupEventModel.new.perform(
                                                  without_venue
                                                )
    end

    def meetup_event_create(param_for_meetup_event_model, venue:, user_id:)
      @meetup_event ||= ::MeetupEvent.new(
        param_for_meetup_event_model.data.merge(
          venue: venue, user_id: user_id
        )
      )
      @meetup_event.save
      return @meetup_event
    end
  end
end
