
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
        uri = Meetup::API::Base.uri_for_search_api_ep(
          URI.join('https://' + API_MEETUP_DOT_COM, 'find/', 'groups'),
          text_to_search,
          QUERY
        )
        res = get_response uri
        return self if not_ok!(res)
        res_body = res.body
        return self if res_body_is_blank!(res_body)
        @data = JSON.parse res_body
        @with_next_event = @data.select { |grp| grp['next_event'] }
        return self
      end

      private

      def res_body_is_blank!(res_body)
        return if res_body and !res_body.strip.empty?
        error_set 'Response body is blank'
        return true
      end
    end
  end
end
