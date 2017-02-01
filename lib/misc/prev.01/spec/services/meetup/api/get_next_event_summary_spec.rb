
require 'support/helpers/webmock'
require 'support/helpers/fixtures'

require 'support/constant'
include RSpecUtil

describe Meetup::API::GetNextEventSummary do
  let(:stubbed_url) { GROUP_WITHOUT_NEXT_EVENT }

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
  it { should respond_to :uri }

  describe '#perform' do
    context 'when input is not meetup.com' do
      subject(:next_event) { described_class.new.perform NOT_MEETUP_DOT_COM }
      include_examples(
        :error, msg: 'HTTP input host is not one of: ' << VALID_HOSTS_STRING
      )
    end

    NOT_A_MEETUP_GROUP_URL = OCRUBY_EVENT_URL
    context 'when input is not a meetup group url' do
      subject(:next_event) do
        described_class.new.perform NOT_A_MEETUP_GROUP_URL
      end

      include_examples(
        :error, msg: "'#{NOT_A_MEETUP_GROUP_URL}' is not a meetup group URL"
      )
    end

    context 'when response is not ok' do
      subject(:next_event) do
        setup_api_stub_request status: 400
        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: /Response .+? is \s+ not \s+ Net::HTTPOK/x
    end

    context 'when response has no next event' do
      subject(:next_event) do
        setup_api_stub_request
        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: 'Group has no next event'
    end

    context 'when response has next event but no event id' do
      subject(:next_event) do
        setup_api_stub_request body: next_event_without_id.to_json

        event = nil
        VCR.turned_off { event = described_class.new.perform stubbed_url }
        event
      end

      include_examples :error, msg: 'Event has no ID'
    end

    context 'when input is valid and response has a next event' do
      subject(:next_event) do
        setup_api_stub_request url: OCRUBY_GROUP_URL,
                               body: OCRUBY_GROUP_RES_BODY.to_json
        event = nil
        VCR.turned_off { event = described_class.new.perform OCRUBY_GROUP_URL }
        event
      end

      describe '#uri' do
        specify do
          uri = URI(
            URI.join(
              OCRUBY_GROUP_URL.sub(/www[.]/, 'api.').sub(%r{ /* \z}x, '/'),
              'events/',
              OCRUBY_GROUP_RES_BODY.fetch('next_event').fetch('id')
            )
          )

          uri.query = ENCODED_API_KEY

          expect(next_event.uri).to eq uri
        end
      end

      include_examples :error
    end
  end
end
