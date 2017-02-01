
module Helpers
  module Controllers
    module MeetupEvents
      # This hack exists because respond_to? doesn't detect this method.
      def default_redirect_fallback
        nil
      end

      def respond_to_wrapper(fallback_location: nil, options: {})
        # This hack exists because respond_to? doesn't detect this method.
        fallback_location ||= default_redirect_fallback || root_path

        respond_to do |format|
          format.js do
            redirect_back options.merge(fallback_location: fallback_location)
          end
          # format.js { render :error, errors: meetup_event.error }
        end
      end

      def errors?(object, fallback_location: nil, flash_error: true)
        error_messages = nil

        if object.is_a?(ApplicationRecord)
          errors = object.errors
          return if errors.count.zero?
          error_messages = errors.full_messages.join(', ')
        else
          error = object.error
          return if !error
          error_messages = error
        end

        if flash_error
          respond_to_wrapper fallback_location: fallback_location,
                             options: { flash: { danger: error_messages } }
        end

        return true
      end

      def meetup_events_as_json_helper(ids_in_cookie_container, current_user)
        selected_events = \
          if current_user
            MeetupEvent.where(user_id: current_user.id)
          else
            MeetupEvent.find(ids_in_cookie_container)
          end

        return group_by_venue(selected_events).collect do |_venue_id, events|
          {
            'events' => events.map do |event|
              event_as_json = event.as_json
              event_as_json.merge(user: event.user.as_json)
            end,

            'venue' => events.first.venue.as_json
          }
        end
      end

      def group_by_venue(events)
        events.reduce({}) do |memo, event|
          venue_id = event.venue.venue_id
          events_in_same_venue = memo[venue_id] || []
          memo.update(venue_id => events_in_same_venue << event)
        end
      end
    end
  end
end
