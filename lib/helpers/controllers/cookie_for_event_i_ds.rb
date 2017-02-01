
module Helpers
  module Controllers
    module CookieForEventIDs
      MEETUP_EVENT_IDS_KEY = :meetup_event_ids

      private_constant :MEETUP_EVENT_IDS_KEY

      def add_to_cookie_for_event_ids(event_id)
        ids = event_ids_in_cookie
        ids.delete event_id
        ids.push event_id

        cookies[MEETUP_EVENT_IDS_KEY] = ids.to_json
      end

      def event_ids_in_cookie
        meetup_event_ids_cookie = cookies[MEETUP_EVENT_IDS_KEY]
        if  meetup_event_ids_cookie and
            meetup_event_ids_cookie != 'undefined'
          return ActiveSupport::JSON.decode(meetup_event_ids_cookie)
        end

        return []
      end

      def delete_event_ids_cookie
        cookies.delete(MEETUP_EVENT_IDS_KEY)
      end
    end
  end
end
