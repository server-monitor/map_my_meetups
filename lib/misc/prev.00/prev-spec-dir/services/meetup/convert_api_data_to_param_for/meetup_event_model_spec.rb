
require 'support/helpers/fixtures'

describe Meetup::ConvertAPIDataToParamFor::MeetupEventModel do
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

  context 'when api data arg is not a hash' do
    subject(:param_for_meetup_event) { described_class.new.perform('!Hash') }
    include_examples :error, msg: /API data arg .+? is not a hash/
  end

  context 'when api data is valid' do
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

    subject(:param_for_meetup_event) do
      described_class.new.perform(event_data_from_api)
    end

    let(:expected) do
      ATTRIBUTES_CONV_TABLE
        .reduce({}) do |memo, (model_attr_name, key_used_by_api)|
          key_used_by_api ||= model_attr_name.to_s
          memo.merge(model_attr_name => event_data_from_api[key_used_by_api])
        end
    end

    describe '#data' do
      specify { expect(subject.data).to eq expected }
    end

    include_examples :error
  end
end
