
describe 'Meetup map' do
  context 'when there are no inputs' do
    describe 'map', js: true, selenium_chrome: true do
      before { visit map_meetup_events_path }
      specify 'should be displayed' do
        expect(page).to have_selector RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS
      end
    end
  end

  context 'when input is a valid event' do
    describe 'next event', js: true, selenium_chrome: true, vcr: false do
      let(:meetup_event_url) do
        # Not the OC Ruby event in our constants
        'http://www.meetup.com/ocruby/events/232306607/'
      end

      let(:meetup_event_title) do
        'Orange County Ruby Users Group (OCRuby) Meetup'
      end

      let(:expected_attributes) do
        {
          # Transient...
          time: 1_469_152_800_000,
          meetup_dot_com_id: 'npbsclyvkblc',
          link: meetup_event_url,

          # Prob. permanent forever. TODO, change to decimal.
          utc_offset: -25_200_000.to_s,
          name: meetup_event_title
        }.stringify_keys.freeze
      end

      let(:expected_venue) do
        {
          # Location permanent (so far) for this group...
          name: 'Eureka Bldg',
          latitude: 33.69908142089844,
          longitude: -117.84720611572266,
          address: '1621 Alton Parkway',
          city: 'Irvine',
          state: 'CA',
          country: 'us'
        }.stringify_keys.freeze
      end

      before do
        visit map_meetup_events_path
        fill_in RSpecUtil::MeetupFormID, with: meetup_event_url
        sleep 1
        click_on 'Submit'
        sleep 2
      end

      let(:meetup_event) { MeetupEvent.first }

      specify { expect(meetup_event.as_json).to include expected_attributes }

      describe '#venue', vcr: false do
        subject { meetup_event.venue.as_json }
        it { should include expected_venue }
      end

      specify do
        within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
          # Google changed this thing from area to div.
          expect(page).to have_xpath %{//div[@title="#{meetup_event_title}"]}
        end
      end
    end
  end
end
