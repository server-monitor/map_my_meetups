
require_relative './base'

module Meetup
  class GetEventData
    include Meetup::Base

    def perform(input_text, uri)
      next_event_uri = \
        if input_text.event?
          uri
        else
          summary = summary_get uri.to_s

          return self if error_in? summary

          summary.uri
        end

      event_data = event_data_get next_event_uri.to_s

      return self if error_in? event_data
      return event_data
    end

    private

    def summary_get(uri_string)
      @summary ||= Meetup::API::GetNextEventSummary.new.perform(uri_string)
    end

    def event_data_get(next_event_uri_string)
      @event_data ||= Meetup::API::GetEventData.new.perform(
        next_event_uri_string
      )
    end
  end
end
