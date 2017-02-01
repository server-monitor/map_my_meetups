
describe(
  File.basename(__FILE__, '.rb').sub(/\_+/, ' ').sub(/_spec/, '').humanize,
  js: true, selenium_chrome: true, vcr: false
) do
  INPUTS = [
    {
      meetup_url: 'http://www.meetup.com/ocruby/events/232799633/',
      title: 'Orange County Ruby Users Group (OCRuby) Meetup'
    },
    {
      meetup_url: 'https://www.meetup.com/SGVTech/events/xknvdlyvlbcb/',
      title: 'PIC Programming, OpenSCAD, KiCad and All things Embedded'
    },

    # Group instead of event but we're only looking for the title.
    # This group is fairly consistent.
    # Hopefully the title doesn't change ever.
    {
      meetup_url: 'https://www.meetup.com/Westside-Rails-Study-Group/',
      title: "Let's study RoR together"
    }
  ].freeze

  # The ideal test: enter 3 events, page shouldn't reload but
  #   the markers should appear.
  before do
    visit map_meetup_events_path
    sleep 2
    INPUTS.each do |meetup_url:, **_|
      fill_in RSpecUtil::MeetupFormID, with: meetup_url
      click_on 'Submit'
      sleep 2
    end

    sleep 2
  end

  INPUTS.each do |meetup_url:, title:|
    context "when input is '#{meetup_url}'" do
      let(:xpath) { %{//div[@title="#{title}"]} }
      # Google changed this thing from area to div?
      # let(:xpath) { %{//area[@title="#{title}"]} }

      specify do
        within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
          # Ideally, what I'd like is for this to auto wait but from
          #   observation it seems it finds the xpath, hover is executed,
          #   then recenters the map.
          #   But it happens so fast that's why the content is not found.
          #   Sleeping is the best band-aid for now.
          sleep 2

          # Hover or click, whatevs...
          page.find(:xpath, xpath).click
          # page.find(:xpath, xpath).hover
          expect(page).to have_content title
        end
      end
    end
  end
end
