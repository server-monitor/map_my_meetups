
require 'support/helpers/webmock'
require 'support/helpers/fixtures'

require 'support/constant'
include RSpecUtil

describe Meetup::API::GetEventData do
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
  it { should respond_to :without_venue }
  it { should respond_to :venue }
  it { should respond_to :data }

  describe '#perform' do
    let(:stubbed_url) { OCRUBY_EVENT_URL }

    context 'when input is not meetup.com' do
      subject(:event_data) do
        described_class.new.perform NOT_MEETUP_DOT_COM
      end

      include_examples(
        :error, msg: 'HTTP input host is not one of: ' << VALID_HOSTS_STRING
      )
    end

    NOT_AN_EVENT_URL = OCRUBY_GROUP_URL
    context 'when input is not an event url' do
      subject(:event_data) do
        described_class.new.perform NOT_AN_EVENT_URL
      end

      include_examples(
        :error, msg: "'#{NOT_AN_EVENT_URL}' is not a meetup event URL"
      )
    end

    context 'when response is not ok' do
      subject(:event_data) do
        setup_api_stub_request status: 400
        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: /Response .+? is \s+ not \s+ Net::HTTPOK/x
    end

    context 'when response is ok but event has no venue' do
      subject(:event_data) do
        setup_api_stub_request
        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: 'Event has no venue'
    end

    context 'when venue is present but it has no lat(itude)' do
      subject(:event_data) do
        setup_api_stub_request body: event_data_from_api_without(:lat).to_json

        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: 'Venue has no lat(itude)'
    end

    context 'when venue is present but it has no lon(gitude)' do
      subject(:event_data) do
        setup_api_stub_request body: event_data_from_api_without(:lon).to_json

        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: 'Venue has no lon(gitude)'
    end

    context 'when venue is valid' do
      subject(:event_data) do
        setup_api_stub_request body: event_data_from_api.to_json
        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      describe '#without_venue' do
        specify do
          without_venue = JSON.parse event_data_from_api.to_json
          without_venue.delete 'venue'
          expect(event_data.without_venue).to eq without_venue
        end
      end

      describe '#venue' do
        specify do
          expect(event_data.venue).to eq event_data_from_api.fetch 'venue'
        end
      end

      describe '#data' do
        specify do
          expect(event_data.data).to eq event_data_from_api
        end
      end

      include_examples :error
    end
  end
end
