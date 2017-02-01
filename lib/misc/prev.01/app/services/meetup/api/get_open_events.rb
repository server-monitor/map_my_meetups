
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
        uri = uri_for_find_events_api_ep text_to_search
        res = get_response uri
        return self if not_ok!(res)
        res_body = res.body
        return self if res_body_is_blank!(res_body)

        @data = data_get res_body
        @with_valid_venue = valid_venue_get @data
        return self
      end

      private

      def data_get(res_body)
        parsed = JSON.parse res_body

        Struct.new(:results, :meta)
              .new(parsed['results'], parsed['meta'])
      end

      def valid_venue_get(data)
        data.results
            .select { |ev| ev['venue'] }
            .select do |ev|
              ev['venue']['lat'] != 0 and ev['venue']['lon'] != 0
            end
      end

      def uri_for_find_events_api_ep(text_to_search)
        uri = URI.join('https://' + API_MEETUP_DOT_COM, '2/', 'open_events')
        uri.query = URI.encode_www_form(sign: true)

        QUERY.merge(text: text_to_search).sort.each do |qkey, qparam|
          # https://stackoverflow.com/questions/16623421/ruby-how-to-add-a-param-to-an-url-that-you-dont-know-if-it-has-any-other-param
          ar = URI.decode_www_form(uri.query) << [qkey, qparam]
          uri.query = URI.encode_www_form(ar)
        end

        return uri
      end

      def res_body_is_blank!(res_body)
        return if res_body and !res_body.strip.empty?
        error_set 'Response body is blank'
        return true
      end
    end
  end
end
