
require 'support/helpers/webmock'
require 'support/helpers/fixtures'

require 'support/constant'
include RSpecUtil

describe MeetupEventsController do
  def post_create(input_text = '')
    process(
      :create,
      method: :post,
      params: { input_text: input_text },
      format: :js
    )
  end

  shared_examples :event_count_should_not_change do
    it 'should not change MeetupEvent count' do
      expect { post_create_call }.not_to change { MeetupEvent.count }
    end
  end

  shared_examples :event_count_should_change_by_1 do
    it 'should change MeetupEvent count' do
      expect { post_create_call }.to change { MeetupEvent.count }.by 1
    end
  end

  shared_examples :error do |danger = nil|
    describe 'error' do
      before { post_create_call }

      if danger
        describe 'flash[:danger]' do
          it { should set_flash[:danger].to danger }
        end

        describe 'redirect' do
          it { should redirect_to map_meetup_events_path }
        end
      else
        it { should_not set_flash }
      end
    end
  end

  context 'when input text is blank' do
    let(:post_create_call) { post_create }

    include_examples :event_count_should_not_change
    include_examples(
      :error, 'Must enter meetup group, event or keyword to search'
    )
  end

  context 'when input text is ' << TEXT_WITH_SPACE do
    let(:post_create_call) { post_create TEXT_WITH_SPACE }
    include_examples :event_count_should_not_change
    include_examples :error, 'Space is an invalid character (TODO)'
  end

  context 'when input is not meetup.com' do
    let(:post_create_call) { post_create NOT_MEETUP_DOT_COM }
    include_examples :event_count_should_not_change
    include_examples :error, 'HTTP input host is not one of: ' <<
                             VALID_HOSTS_STRING
  end

  context 'when response is not ok' do
    let(:post_create_call) do
      setup_api_stub_request status: 400
      VCR.turned_off { post_create stubbed_url }
    end

    include_examples :event_count_should_not_change
    include_examples :error, /Response .+? is \s+ not \s+ Net::HTTPOK/x
  end

  context 'when input url is an event' do
    let(:stubbed_url) { OCRUBY_EVENT_URL }

    context 'when event has no venue' do
      let(:post_create_call) do
        setup_api_stub_request
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :event_count_should_not_change
      include_examples :error, 'Event has no venue'
    end

    context 'when venue is present but it has no lat(itude)' do
      let(:post_create_call) do
        setup_api_stub_request body: event_data_from_api_without(:lat).to_json
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :event_count_should_not_change
      include_examples :error, 'Venue has no lat(itude)'
    end

    context 'when venue is present but it has no lon(gitude)' do
      let(:post_create_call) do
        setup_api_stub_request body: event_data_from_api_without(:lon).to_json
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :event_count_should_not_change
      include_examples :error, 'Venue has no lon(gitude)'
    end

    context 'when event url is valid' do
      let(:post_create_call) do
        setup_api_stub_request body: event_data_from_api.to_json
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :event_count_should_change_by_1
      include_examples :error

      describe 'newly created meetup event' do
        before { post_create_call }
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
          post_create_call
          # Something happens inside post_create_call if called 2x.
          # It wouldn't post 2x. Investigate later.
          post_create stubbed_url
          expect(MeetupEvent.count).to eq 1
        end
      end

      describe 'meetup_event_ids cookie' do
        before do
          VCR.use_cassette 'controllers/meetup_events/create_spec/cookies' do
            # These groups are pretty consistent with having events.
            # If it makes sense, check first if these groups have events
            #   if this example group fails.
            post_create 'https://www.meetup.com/laruby/'
            post_create 'https://www.meetup.com/Learn-JavaScript/'
            post_create 'https://www.meetup.com/SGVTech/'
          end
        end

        specify do
          ids_from_cookie = ActiveSupport::JSON.decode(
            cookies.fetch(:meetup_event_ids)
          )
          expect(ids_from_cookie.sort).to eq MeetupEvent.pluck(:id).sort
        end
      end
    end
  end

  # Group
  def stubbed_url
    GROUP_WITHOUT_NEXT_EVENT
  end

  context 'when group has no next event' do
    let(:post_create_call) do
      setup_api_stub_request
      VCR.turned_off { post_create stubbed_url }
    end

    include_examples :event_count_should_not_change
    include_examples :error, 'Group has no next event'
  end

  context 'when next event has no event id' do
    let(:post_create_call) do
      setup_api_stub_request body: next_event_without_id.to_json
      VCR.turned_off { post_create stubbed_url }
    end

    include_examples :event_count_should_not_change
    include_examples :error, 'Event has no ID'
  end

  context 'when group input is valid' do
    let(:post_create_call) do
      # Verified same data by looking URLs on meetup.com
      hack_different_id_but_same_data = OCRUBY_EVENT_URL.sub(
        '232799633', 'npbsclyvlbhc'
      )
      setup_api_stub_request url: hack_different_id_but_same_data,
                             body: event_data_from_api.to_json
      setup_api_stub_request url: OCRUBY_GROUP_URL,
                             body: OCRUBY_GROUP_RES_BODY.to_json
      VCR.turned_off { post_create OCRUBY_GROUP_URL }
    end

    it 'should change MeetupEvent count' do
      expect { post_create_call }.to change { MeetupEvent.count }.by 1
    end

    include_examples :error
  end
end
