
describe(
  RSpecUtil.humanize_bname, js: true, selenium_chrome: true, vcr: false
) do
  let(:inputs) do
    # rubocop:disable Metrics/LineLength
    [
      {
        meetup_url: 'https://www.meetup.com/peoplespace/events/232894877/',
        title: 'The Javascript You Wish to Know - Community School'
      },
      {
        meetup_url: 'http://www.meetup.com/Free-Code-Camp-Orange-County-CA/events/233133633/',
        title: 'First Thursday of the Month at PeopleSpace - JavaScript/HTML/CSS'
      }
    ].freeze
    # rubocop:enable Metrics/LineLength
  end

  before do
    visit map_meetup_events_path
    sleep 1

    inputs.each do |meetup_url:, **_|
      fill_in RSpecUtil::MeetupFormID, with: meetup_url
      sleep 1
      click_on 'Submit'
    end

    sleep 2
  end

  let(:first_event_title) { inputs.first.fetch :title }

  let(:xpath) { %{//div[@title="#{first_event_title}"]} }
  # Google changed this thing from area to div?
  # let(:xpath) { %{//area[@title="#{title}"]} }

  specify do
    within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
      # If hover...
      #   Ideally, what I'd like is for this to auto wait but from
      #   observation it seems it finds the xpath, hover is executed,
      #   then recenters the map.
      #   But it happens so fast that's why the content is not found.
      #   Sleeping is the best band-aid for now.
      # sleep 2

      # Hover or click, whatevs...
      page.find(:xpath, xpath).click
      # page.find(:xpath, xpath).hover

      # Combined specs because this takes too long to setup.
      expect(page).to have_content first_event_title
    end
  end
end
