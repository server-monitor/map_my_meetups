
require 'uri'
require 'support/helpers/webmock'

require 'support/fixtures/get_open_events'
require 'support/fixtures/events'

shared_examples :when_input_is_keyword_to_search do
  context 'when input is keyword to search' do
    let(:text_to_search) { 'perl' }

    let(:stubbed_url) do
      Fixture::GetOpenEvents.uri_for_get_open_events_api_ep(text_to_search).to_s
    end

    let(:fixture_response_body) do
      Fixture::GetOpenEvents.response_body_of_search_term(text_to_search)
    end

    let(:post_create_call) do
      setup_api_stub_request body: fixture_response_body.to_json
      VCR.turned_off { post_create text_to_search }
    end

    let(:expected_events_with_valid_venue) do
      fixture_response_body['results']
        .select { |ev| ev['venue'] }
        .select do |ev|
          ev['venue']['lat'] != 0 and ev['venue']['lon'] != 0
        end
    end

    describe 'event names' do
      specify do
        post_create_call
        expect(MeetupEvent.all.map(&:name))
          .to eq expected_events_with_valid_venue.map { |ev| ev['name'] }
      end
    end

    context 'when event exists' do
      it 'should not be entered into the database' do
        post_create_call
        post_create text_to_search
        expect(MeetupEvent.count).to eq expected_events_with_valid_venue.count
      end
    end
  end
end
