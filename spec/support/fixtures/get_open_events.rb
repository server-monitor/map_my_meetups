
require 'uri'

require 'support/constant'
include RSpecUtil

module Fixture
  module GetOpenEvents
    class << self
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

      def uri_for_get_open_events_api_ep(text_to_search)
        uri = URI.join(HTTPS_API, '2/', 'open_events')
        uri.query = URI.encode_www_form(sign: true)

        QUERY.merge(text: text_to_search).sort.each do |qkey, qparam|
          # https://stackoverflow.com/questions/16623421/ruby-how-to-add-a-param-to-an-url-that-you-dont-know-if-it-has-any-other-param
          ar = URI.decode_www_form(uri.query) << [qkey, qparam]
          uri.query = URI.encode_www_form(ar)
        end

        return uri
      end

      def response_body_of_search_term(the_term)
        file = File.join(File.dirname(__FILE__), 'json', the_term + '.json')

        JSON.parse File.read file
      end
    end
  end
end
