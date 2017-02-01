
require 'support/helpers/fixtures'

# Ideally, this integration should be from ...
#   Meetup::InputText =>
#   Meetup::API::GetNextEventSummary =>
#   Meetup::API::GetEventData =>
#   Meetup::ConvertAPIDataToParamFor::MeetupEventModel =>
#   MeetupEvent

describe MeetupEvent do
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

  context 'when param for meetup_event model is not a hash' do
    subject(:meetup_event) { described_class.new('Should be invalid, right?') }
    specify { expect { subject }.to raise_error ArgumentError }
  end

  context 'when param for meetup_event model is valid' do
    let(:param_for_meetup_event) do
      Meetup::ConvertAPIDataToParamFor::
              MeetupEventModel.new.perform(event_data_from_api)
    end

    subject(:meetup_event) do
      venue_params = Meetup::ConvertAPIDataToParamFor::
                             VenueModel.new.perform(venue_data_from_api)

      venue = Venue.new(venue_params.data)
      # venue.save!
      place = described_class.new(
        param_for_meetup_event.data.merge(venue: venue)
      )

      place.save
      place
    end

    include_examples :expected_count, 1
    include_examples :errors, count_greater_than_zero: false
  end
end
