
require_relative './base'
require_relative './api/base'

module Meetup
  class SearchEvents
    include Meetup::Base
    include Meetup::API::Base

    attr_reader :result

    def perform(groups_with_next_event, user_id)
      @user_id = user_id

      # groups = find_groups text_to_search
      # return self if error? groups

      @events_data_from_api = events_data_from_api_get groups_with_next_event
      @events = events_get events_data_from_api
      @result = result_get

      return self
    end

    # def perform(text_to_search, user_id)
    #   @user_id = user_id

    #   groups = find_groups text_to_search
    #   return self if error? groups

    #   @events_data_from_api = events_data_from_api_get groups.data
    #   @events = events_get events_data_from_api
    #   @result = result_get groups

    #   return self
    # end

    private

    attr_reader :user_id, :events_data_from_api, :events

    # def find_groups(text_to_search)
    #   Meetup::API::FindGroups.new.perform text_to_search
    # end

    def error?(groups)
      err = groups.error
      return if !err
      error_set err
      return true
    end

    def result_get
      event_ids = events ? events.map(&:id) : []

      Struct.new(:events, :event_ids)
            .new(events,   event_ids)
    end

    # def result_get(groups)
    #   event_ids = events ? events.map(&:id) : []

    #   Struct.new(:events, :event_ids)
    #         .new(
    #           events,
    #           event_ids
    #         )
    #   # Struct.new(:from_api, :events, :event_ids)
    #   #       .new(
    #   #         from_api_get(groups.data),
    #   #         events,
    #   #         event_ids
    #   #       )
    # end

    # def from_api_get(grps_data)
    #   next_events = grps_data.select { |grp| grp['next_event'] }

    #   return Struct
    #          .new(:groups_found, :next_events)
    #          .new(grps_data,     next_events)
    # end

    def events_data_from_api_get(grps_data)
      grps_data
        .select { |grp| grp['next_event'] }
        .collect do |grp|
          event_id = grp['next_event']['id']
          Struct.new(:meetup_dot_com_id, :uri).new(
            event_id, event_uri_get(grp['link'], event_id)
          )
        end
    end

    def events_get(events_data_from_api)
      list = []

      events_data_from_api.each do |api|
        event = MeetupEvent.find_by(meetup_dot_com_id: api.meetup_dot_com_id)
        if event
          list.push event
          next
        end
        # next if MeetupEvent.find_by(meetup_dot_com_id: api.meetup_dot_com_id)
        event_data = Meetup::API::GetEventData.new.perform(api.uri.to_s)
        next if ed_error? event_data
        sleep 1 if !Rails.env.test?
        list.push(Meetup::CreateEvent.new.perform(event_data, user_id))
      end
      return list
    end

    def ed_error?(event_data)
      if event_data.error
        Rails.logger.warn "Errors in searching events... #{event_data.error}"
        return true
      end
    end
  end
end
