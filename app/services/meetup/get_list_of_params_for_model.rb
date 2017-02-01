
require_relative './base'

module Meetup
  class GetListOfParamsForModel
    include Meetup::Base

    attr_reader :list

    def perform(params_input)
      input_text = Meetup::InputText.new params_input
      error = input_text.error
      if error
        @searched_for_only_one_event = true
        error_set error
        return self
      end

      uri = input_text.validated_uri?

      events_data_from_api = \
        if uri
          searched_for_only_one_event input_text, uri
        else
          search_for_multiple_events input_text.to_s
        end

      @list = events_data_from_api

      return self
    end

    def searched_for_only_one_event?
      @searched_for_only_one_event
    end

    private

    def item_format(existing_event: nil, params: nil, errors_wrapper: nil)
      {
        existing_event: existing_event,
        params: params,
        errors_wrapper: errors_wrapper
      }
      # Struct.new(:event, :params, :errors_wrapper)
      #       .new(event,  params,  errors_wrapper)
    end

    def searched_for_only_one_event(input_text, uri)
      @searched_for_only_one_event = true

      just_a_string = input_text.to_s
      event = MeetupEvent.find_by(link: just_a_string)
      event ||= MeetupEvent.find_by(
        link: just_a_string.sub(%r{ https:// }x, 'http://')
      )
      return [item_format(existing_event: event)] if event

      event_data = Meetup::GetEventData.new.perform(input_text, uri)
      params = nil
      error = event_data.error

      if error
        error_set error
        params = { errors_wrapper: event_data }
      else
        meetup_dot_com_id = event_data.without_venue['id']
        event = MeetupEvent.find_by meetup_dot_com_id: meetup_dot_com_id

        params = event ? { existing_event: event } : { params: event_data }
      end

      return [item_format(params)]
    end

    def search_for_multiple_events(text_string)
      raw = Meetup::API::GetOpenEvents.new.perform(text_string)

      validated_list = []
      if raw.error
        validated_list.push item_format(errors_wrapper: raw)
      else
        raw.with_valid_venue.each do |edfa|
          meetup_dot_com_id = edfa['id']
          event = MeetupEvent.find_by meetup_dot_com_id: meetup_dot_com_id

          if event
            validated_list.push(item_format(existing_event: event))
            next
          end

          validated_list.push(
            item_format(
              #                          \/\/ hash without venue key
              params: Struct.new(:venue, :without_venue)
                            .new(edfa['venue'], edfa)
            )
          )
        end
      end

      return validated_list
    end
  end
end
