
require 'json'

require_relative '../constant'
require_relative '../base'
require_relative './base'

module Meetup
  module API
    class GetOpenEvents
      include Meetup::Constant
      include Meetup::Base
      include Meetup::API::Base

      attr_reader :data, :with_valid_venue

      QUERY = {
        # text: 'The_keyword_to_search.',
        # sign: true,
        # 'photo-host': 'public',

        # Somewhere in Downey, CA, between LA and OC.
        lon: -118.100593,
        lat: 33.939858,
        radius: 120,

        page: (ENV['EVENTS'].strip.empty? ? 100 : ENV['EVENTS'].to_s),
        omit: 'description,organizer,photos,group_photo,key_photo'
      }.freeze

      private_constant :QUERY

      def perform(text_to_search)
        uri = Meetup::API::Base.uri_for_search_api_ep(
          URI.join('https://' + API_MEETUP_DOT_COM, '2/', 'open_events'),
          text_to_search,
          QUERY
        )
        res = get_response uri
        return self if not_ok!(res)
        res_body = res.body
        return self if res_body_is_blank!(res_body)

        @data = self.class.data_get res_body
        @with_valid_venue = self.class.valid_venue_get @data
        return self
      end

      private

      class << self
        def data_get(res_body)
          parsed = JSON.parse res_body

          results = parsed['results']

          results.map { |ev| ev.update('link' => ev['event_url']) }

          Struct.new(:results, :meta)
                .new(results, parsed['meta'])
        end

        def valid_venue_get(data)
          data.results
              .select do |ev|
                ev['venue'] and
                  ev['venue']['lat'].nonzero? and
                  ev['venue']['lon'].nonzero?
              end
        end
      end

      def res_body_is_blank!(res_body)
        return if res_body and !res_body.strip.empty?
        error_set 'Response body is blank'
        return true
      end
    end
  end
end
