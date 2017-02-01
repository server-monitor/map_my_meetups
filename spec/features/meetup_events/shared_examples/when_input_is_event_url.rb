
shared_examples :input_validations_when_input_is_event_url do
  context 'when input url is an event' do
    let(:stubbed_url) { OCRUBY_EVENT_URL }

    context 'when event has no venue' do
      before do
        setup_api_stub_request
        submit stubbed_url
      end

      include_examples :event_count_should_be_zero
      include_examples :input_validations_error, 'Event has no venue'
    end

    context 'when venue is present but it has no lat(itude)' do
      before do
        setup_api_stub_request body: event_data_from_api_without(:lat).to_json
        submit stubbed_url
      end

      include_examples :event_count_should_be_zero
      include_examples :input_validations_error, 'Venue has no lat(itude)'
    end

    context 'when venue is present but it has no lon(gitude)' do
      before do
        setup_api_stub_request body: event_data_from_api_without(:lon).to_json
        submit stubbed_url
      end
      include_examples :event_count_should_be_zero
      include_examples :input_validations_error, 'Venue has no lon(gitude)'
    end

    context 'when event url is valid' do
      before do
        setup_api_stub_request body: event_data_from_api.to_json
        submit stubbed_url
      end

      include_examples :event_count_should_eq_1
      include_examples :input_validations_error

      describe 'newly created meetup event' do
        let(:meetup_event) { MeetupEvent.first }
        specify do
          expect(event_data_from_api).to include(
            %w[name link].reduce({}) do |memo, attri|
              memo.merge(attri => meetup_event.public_send(attri))
            end
          )
        end

        specify do
          expect(event_data_from_api).to include(
            'id' => meetup_event.meetup_dot_com_id,
            'time' => meetup_event.time,
            'utc_offset' => meetup_event.utc_offset.to_i
          )
        end

        specify do
          # id: 3,
          # meetup_event_id: 3,

          # name: "Eureka Bldg",
          # repinned: false,
          # city: "Irvine",
          # state: "CA",
          # country: "us",

          # zip: nil,

          # venue_id: 21898262,
          # latitude: #<BigDecimal:7f8ddf586820,'0.3369908142 089844E2',27(36)>,
          # longitude:
          #   #<BigDecimal:7f8ddf586488,'-0.1178472061 157227E3',27(36)>,
          # address: "1621 Alton Parkway",

          venue = meetup_event.venue
          expect(venue_data_from_api).to include(
            %w[name repinned city state country].reduce({}) do |memo, attri|
              memo.merge(attri => venue.public_send(attri))
            end.merge(
              'zip' => venue.zip || '',
              'id' => venue.venue_id,
              'lat' => venue.latitude,
              'lon' => venue.longitude,
              'address_1' => venue.address
            )
          )
        end
      end

      context 'when event exists' do
        it 'the same event should not be entered into the database' do
          # before block enters the first stubbed_url,
          #   then the following enters the same URL
          submit stubbed_url
          expect(MeetupEvent.count).to eq 1
        end
      end

      describe 'meetup_event_ids cookie' do
        before do
          submit [
            'https://www.meetup.com/laruby/',
            'https://www.meetup.com/Learn-JavaScript/',
            'https://www.meetup.com/SGVTech/'
          ]
        end

        specify do
          ids_from_cookie = ActiveSupport::JSON.decode(
            URI.unescape(
              Capybara.current_session.driver.browser.manage.cookie_named(
                'meetup_event_ids'
              ).fetch(:value)
            )
          )
          expect(ids_from_cookie.sort).to eq MeetupEvent.pluck(:id).sort
        end
      end
    end
  end
end
