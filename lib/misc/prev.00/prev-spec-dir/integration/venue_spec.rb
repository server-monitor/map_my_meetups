
require 'support/helpers/fixtures'

# Ideally, this integration should be from ...
#   Meetup::InputText =>
#   Meetup::API::GetNextEventSummary =>
#   Meetup::API::GetEventData =>
#   Meetup::ConvertAPIDataToParamFor::VenueModel =>
#   Venue

describe Venue do
  shared_examples :errors do |count_greater_than_zero: false, msg: nil|
    describe '#errors' do
      let(:errors) { subject.errors }

      if count_greater_than_zero
        describe '#count' do
          specify { expect(errors.count).to be > 0 }
        end

        describe 'msg(s)' do
          specify { expect(errors.full_messages).to include msg }
        end
      else
        describe '#count' do
          specify { expect(errors.count).to be == 0 }
        end
      end
    end
  end

  shared_examples :expected_count do |count|
    describe '::count' do
      before { subject.save }
      specify { expect(described_class.count).to eq count }
    end
  end

  context 'when param for venue model is not a hash' do
    subject(:venue) { described_class.new('Should be invalid, right?') }
    specify { expect { subject }.to raise_error ArgumentError }
  end

  context 'when param for venue model is a hash but it has no lat(itude)' do
    let(:param_for_venue) do
      Meetup::ConvertAPIDataToParamFor::
              VenueModel.new.perform(venue_without_lat)
    end

    subject(:venue) do
      place = described_class.new(param_for_venue.data)
      place.save
      place
    end

    include_examples :expected_count, 0

    include_examples(
      :errors, count_greater_than_zero: true, msg: "Latitude can't be blank"
    )
  end

  context 'when param for venue model is a hash but it has no lon(itude)' do
    let(:param_for_venue) do
      Meetup::ConvertAPIDataToParamFor::
              VenueModel.new.perform(venue_without_lon)
    end

    subject(:venue) do
      place = described_class.new(param_for_venue.data)
      place.save
      place
    end

    include_examples :expected_count, 0

    include_examples(
      :errors, count_greater_than_zero: true, msg: "Longitude can't be blank"
    )
  end

  context 'when param for venue model is valid' do
    let(:param_for_venue) do
      Meetup::ConvertAPIDataToParamFor::
              VenueModel.new.perform(venue_data_from_api)
    end

    subject(:venue) do
      meetup_event = MeetupEvent.new
      place = described_class.new(
        param_for_venue.data.merge(meetup_event: meetup_event)
      )
      place.save
      place
    end

    include_examples :expected_count, 1
    include_examples :errors, count_greater_than_zero: false
  end
end
