
require 'support/helpers/webmock'
require 'support/fixtures/get_open_events'

require 'support/constant'
include RSpecUtil

describe Meetup::API::GetOpenEvents do
  shared_examples :error do |msg: nil|
    describe '#error' do
      specify do
        eq_or_match = msg.is_a?(Regexp) ? :match : :eq
        expect(subject.error).to public_send eq_or_match, msg
      end
    end
  end

  it { should respond_to :error }
  it { should respond_to :error_set }
  it { should respond_to(:perform).with(1).argument }
  it { should respond_to :data }
  it { should respond_to :with_valid_venue }

  describe '#perform' do
    let(:text_to_search) { 'perl' }

    let(:stubbed_url) do
      Fixture::GetOpenEvents.uri_for_get_open_events_api_ep(text_to_search).to_s
    end

    def perform_search(search_this = nil)
      search_this ||= text_to_search
      evs = nil
      VCR.turned_off { evs = described_class.new.perform search_this }
      return evs
    end

    context 'when response is not ok' do
      subject(:open_events) do
        setup_api_stub_request status: 400
        perform_search
      end

      include_examples :error, msg: /Response .+? is \s+ not \s+ Net::HTTPOK/x
    end

    context 'when response is ok' do
      context 'when res body is blank' do
        subject(:open_events) do
          setup_api_stub_request url: stubbed_url
          perform_search
        end

        include_examples :error, msg: 'Response body is blank'
      end

      context 'when res body contain valid data' do
        let(:fixture_response_body) do
          Fixture::GetOpenEvents.response_body_of_search_term(text_to_search)
        end

        let(:fixture_response_body_with_link) do
          results = fixture_response_body['results']
          results.map { |ev| ev.update('link' => ev['event_url']) }
        end

        let(:expected_events_with_valid_venue) do
          fixture_response_body_with_link
            .select do |ev|
              ev['venue'] and
                ev['venue']['lat'].nonzero? and
                ev['venue']['lon'].nonzero?
            end
        end

        subject(:open_events) do
          setup_api_stub_request(
            url: stubbed_url,
            body: fixture_response_body.to_json
          )

          perform_search
        end

        include_examples :error

        describe '#data' do
          subject(:data) { open_events.data }
          it { should respond_to :results }
          it { should respond_to :meta }

          describe '#data#results' do
            subject(:results) { data.results }

            let(:expected_results) { fixture_response_body_with_link }

            it { should eq expected_results }

            describe '... results total' do
              specify { expect(results.count).to eq expected_results.count }
            end
          end

          describe '#data#meta' do
            specify { expect(data.meta).to eq fixture_response_body['meta'] }
          end
        end

        describe '#with_valid_venue' do
          specify do
            expect(open_events.with_valid_venue)
              .to eq expected_events_with_valid_venue
          end
        end
      end
    end
  end
end
