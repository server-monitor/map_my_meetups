
require_relative '../constant'

require_relative '../base'
require_relative './base'

module Meetup
  module API
    class FindGroups
      include Meetup::Constant
      include Meetup::Base
      include Meetup::API::Base

      attr_reader :data, :with_next_event

      QUERY = {
        # text: 'The_keyword_to_search.',
        # sign: true,
        'photo-host': 'public',

        # Somewhere in Downey, CA, between LA and OC.
        lon: -118.100593,
        lat: 33.939858,
        radius: 75,

        page: (ENV['EVENTS'] || 20),
        omit: 'description,organizer,photos,group_photo,key_photo'
      }.freeze

      private_constant :QUERY

      def perform(text_to_search)
        uri = uri_for_find_groups_api_ep text_to_search
        res = get_response uri
        return self if not_ok!(res)
        res_body = res.body
        return self if res_body_is_blank!(res_body)
        @data = JSON.parse res_body
        @with_next_event = @data.select { |grp| grp['next_event'] }
        return self
      end

      private

      def uri_for_find_groups_api_ep(text_to_search)
        uri = URI.join('https://' + API_MEETUP_DOT_COM, 'find/', 'groups')
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
