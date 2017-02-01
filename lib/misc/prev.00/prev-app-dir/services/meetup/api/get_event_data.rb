
require 'json'

require_relative '../base'

module Meetup
  module API
    class GetEventData
      include Meetup::Base
      include Meetup::Base::Venue

      attr_reader :without_venue, :venue, :data

      def perform(url)
        api_url = convert_to_api_url url
        uri = URI api_url

        return self if !valid_host!(uri.host)
        return self if not_event!(uri, url)

        uri.query = query_get(uri)
        res = Net::HTTP.get_response uri
        return self if not_ok!(res)

        venue = validate_venue res
        return self if error

        raise 'Venue should not be blank' if venue.blank?

        @venue = venue
        @data = JSON.parse res.body
        @without_venue = \
          @data.keys.reject { |key, _| key == 'venue' }
               .reduce({})  { |memo, key| memo.merge(key => @data[key]) }

        return self
      end

      private

      def not_event!(uri, url)
        return if event?(uri.path)
        error_set "'#{url}' is not a meetup event URL"
        return true
      end

      def validate_venue(res)
        venue = venue_get res
        return if no_venue!(venue)
        return if no_coord!(:lat, venue)
        return if no_coord!(:lon, venue)

        return venue
      end

      def venue_get(res)
        json = json_get res
        return json ? json['venue'] : nil
      end

      def no_venue!(venue)
        return if venue
        error_set 'Event has no venue'
        return true
      end
    end
  end
end
