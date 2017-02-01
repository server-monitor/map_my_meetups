
require_relative '../base'

module Meetup
  module ConvertAPIDataToParamFor
    class MeetupEventModel
      include Meetup::Base

      attr_reader :data

      ATTRIBUTES_CONV_TABLE = {
        # Transient...
        meetup_dot_com_id: 'id', time: nil, link: nil,

        # The meetup event name
        name: nil,

        # Prob. have to delete this in the database table since we can now...
        #   ...venue.name
        # venue_name: nil,

        # Prob. permanent forever.
        utc_offset: nil
      }.freeze # if !defined?(ATTRIBUTES_CONV_TABLE)

      def perform(api_data)
        return self if not_hash! api_data, prepend_msg: 'API data arg'

        @data = change_keys_to_match_model_params(
          ATTRIBUTES_CONV_TABLE, api_data
        )

        return self
      end
    end
  end
end
