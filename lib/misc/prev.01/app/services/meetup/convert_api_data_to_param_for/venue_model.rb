
require_relative '../base'

module Meetup
  module ConvertAPIDataToParamFor
    class VenueModel
      include Meetup::Base
      include Meetup::Base::Venue

      ERR_MSG = 'API venue data has no '.freeze

      attr_reader :data

      VENUE_ATTRIBUTES_CONV_TABLE = {
        venue_id: 'id',
        # Commented out because venue.name => venue_name
        name: nil,

        latitude: 'lat',
        longitude: 'lon',

        address: 'address_1',

        city: nil, state: nil, country: nil, zip: nil,
        # localized_country_name: 'USA',

        # Don't know what this is for
        repinned: nil
      }.freeze

      def perform(api_venue_data)
        return self if not_hash! api_venue_data,
                                 prepend_msg: 'API venue data arg'
        return self if no_coord!(
          :lat, api_venue_data, err_msg: ERR_MSG + 'lat(itude)'
        )

        return self if no_coord!(
          :lon, api_venue_data, err_msg: ERR_MSG + 'lon(gitude)'
        )

        @data = change_keys_to_match_model_params(
          VENUE_ATTRIBUTES_CONV_TABLE, api_venue_data
        )

        return self
      end
    end
  end
end
