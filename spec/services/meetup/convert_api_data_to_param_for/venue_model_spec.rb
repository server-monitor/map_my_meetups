
require 'support/helpers/fixtures'

describe Meetup::ConvertAPIDataToParamFor::VenueModel do
  shared_examples :error do |msg: nil|
    describe '#error' do
      specify do
        eq_or_match = (msg.is_a? Regexp) ? :match : :eq
        expect(subject.error).to public_send eq_or_match, msg
      end
    end
  end

  it { should respond_to :error }
  it { should respond_to :error_set }
  it { should respond_to(:perform).with(1).argument }
  it { should respond_to :data }

  context 'when api venue data arg is not a hash' do
    subject(:param_for_venue) { described_class.new.perform('not a hash') }
    include_examples :error, msg: /API venue data .+? is not a hash/
  end

  context 'when api venue data arg is a hash but it has no lat(itude)' do
    subject(:param_for_venue) { described_class.new.perform(venue_without_lat) }
    include_examples :error, msg: 'API venue data has no lat(itude)'
  end

  context 'when api venue data arg is a hash but it has no lon(gitude)' do
    subject(:param_for_venue) { described_class.new.perform(venue_without_lon) }
    include_examples :error, msg: 'API venue data has no lon(gitude)'
  end

  context 'when api venue data is valid' do
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

    subject(:param_for_venue) do
      described_class.new.perform(venue_data_from_api)
    end

    let(:expected) do
      VENUE_ATTRIBUTES_CONV_TABLE
        .reduce({}) do |memo, (model_attr_name, key_used_by_api)|
          key_used_by_api ||= model_attr_name.to_s
          memo.merge(model_attr_name => venue_data_from_api[key_used_by_api])
        end
    end

    describe '#data' do
      specify { expect(subject.data).to eq expected }
    end

    include_examples :error
  end
end
