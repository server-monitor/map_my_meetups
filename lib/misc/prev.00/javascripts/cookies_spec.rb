
describe 'Cookies set by JavaScript', type: :controller do
  pending "I don't know..."

  # # context 'no inputs' do
  # #   describe 'page', js: true, selenium_chrome: true do
  # #     before { visit map_meetup_events_path }
  # #     specify do
  # #       expect(page).to have_selector RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS
  # #     end
  # #   end
  # # end

  # context 'when input is a valid event', js: true, selenium_chrome: true do
  #   let(:meetup_event_url) do
  #     'http://www.meetup.com/ocruby/events/232306607/'
  #   end

  #   # let(:meetup_event_title) do
  #   #   'Orange County Ruby Users Group (OCRuby) Meetup'
  #   # end

  #   # let(:expected_attributes) do
  #   #   {
  #   #     # Transient...
  #   #     time: 1_469_152_800_000.0,
  #   #     meetup_dot_com_id: 'npbsclyvkblc',
  #   #     link: meetup_event_url,

  #   #     # Prob. permanent forever. TODO, change to decimal.
  #   #     utc_offset: -25_200_000.to_s,
  #   #     name: meetup_event_title,
  #   #     venue_name: 'Eureka Bldg'
  #   #   }.stringify_keys.freeze
  #   # end

  #   # let(:expected_venue) do
  #   #   {
  #   #     # Location permanent (so far) for this group...
  #   #     latitude: 33.69908142089844,
  #   #     longitude: -117.84720611572266,
  #   #     address: '1621 Alton Parkway',
  #   #     city: 'Irvine',
  #   #     state: 'CA',
  #   #     country: 'us'
  #   #   }.stringify_keys.freeze
  #   # end

  #   before do
  #     VCR.use_cassette 'views/javascripts/cookies' do
  #       # visit map_meetup_events_path
  #       request.cookies[:user_uuid] = 'abcd'
  #       visit '/meetup_events/map'
  #       fill_in RSpecUtil::MeetupFormID, with: meetup_event_url
  #       click_on 'Submit'
  #       sleep 2
  #     end
  #   end

  #   # let(:meetup_event) { MeetupEvent.first }
  #   # specify { expect(meetup_event.as_json).to include expected_attributes }

  #   # describe '#venue' do
  #   #   subject { meetup_event.venue.as_json }
  #   #   it { should include expected_venue }
  #   # end

  #   specify do
  #     expect(MeetupEvent.count).to eq 1
  #   end

  #   specify do
  #     # should be_truthy
  #     sleep 4
  #     pp resp: response.cookies, ck: cookies
  #     within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
  #       # Google changed this thing from area to div?
  #       expect(page).to have_xpath %{//div[@title="#{meetup_event_title}"]}
  #     end
  #   end
  # end
end
