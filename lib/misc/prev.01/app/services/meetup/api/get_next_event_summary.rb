
require 'uri'

require_relative '../base'
require_relative './base'

module Meetup
  module API
    class GetNextEventSummary
      include Meetup::Base
      include Meetup::API::Base

      attr_reader :uri

      def perform(url)
        api_url = convert_to_api_url url
        uri = URI api_url

        return self if !valid_host!(uri.host)
        return self if not_group!(uri, url)

        res = get_response uri
        return self if not_ok!(res)

        next_event = next_event_get res
        return self if no_next_event!(next_event)

        event_id = next_event['id']
        return self if no_event_id!(event_id)

        @uri = event_uri_get api_url, event_id
        @uri.query = query_get @uri

        return self
      end

      private

      def group?(path)
        path =~ %r{\A / [^/]+ /? \z}x
      end

      def not_group!(uri, original_url)
        if !group?(uri.path)
          error_set "'#{original_url}' is not a meetup group URL"
          return true
        end
      end

      def next_event_get(res)
        json = json_get res
        return json ? json['next_event'] : nil
      end

      def no_next_event!(next_event)
        return if next_event
        error_set 'Group has no next event'
        return true
      end

      def no_event_id!(event_id)
        return if event_id and !event_id.strip.empty?
        error_set 'Event has no ID'
        return true
      end
    end
  end
end
