
# describe User, type: :model do
#   [
#     nil,
#     :with_meetup_events
#   ].each do |factory|
#     context factory || :user do
#       subject do
#         cassette = 'user'
#         params = []
#         if factory
#           cassette += factory.to_s
#           params.push factory
#         end
#         VCR.use_cassette 'models/user/' << cassette do
#           create :user, *params
#         end
#       end

#       it { should respond_to :name }
#       it { should respond_to :email }
#       it { should have_many :meetup_events }
#     end
#   end
# end

describe 'Hover', js: true, selenium_chrome: true, vcr: false do
  pending <<-EOP

      I don't think this testable. The setting of the meetup event IDs cookie is
      independent of the request (because it is done through ActiveJob/WS).
      The request, along with whatever cookies were set by the controller,
      will have a response before the ActiveJob/WS can set the cookies.

      For now, until we figure this out, the best we can do is test the markers
      one-by-one.

  EOP

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

  INPUTS.each do |meetup_url:, title:|
    context "when input is '#{meetup_url}'", vcr: false do
      let(:xpath) { %{//div[@title="#{title}"]} }
      # Google changed this thing from area to div?
      # let(:xpath) { %{//area[@title="#{title}"]} }

      specify do
        visit map_meetup_events_path

        fill_in RSpecUtil::MeetupFormID, with: meetup_url
        sleep 2
        click_on 'Submit'
        sleep 2

        within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
          # Ideally, what I'd like is for this to auto wait but from observation
          #   it seems it finds the xpath, hover is executed,
          #   then recenters the map.
          #   But it happens so fast that's why the content is not found.
          #   Sleeping is the best band-aid for now.
          sleep 2

          # Hover or click, whatevs...
          page.find(:xpath, xpath).click
          # page.find(:xpath, xpath).hover
          expect(page).to have_content title, wait: 10
        end
      end
    end
  end

  # # The ideal test: enter 3 events, page shouldn't reload but
  # #   the markers should appear.
  # before do
  #   visit map_meetup_events_path
  #   sleep 2
  #   INPUTS.each do |meetup_url:, **_|
  #     fill_in RSpecUtil::MeetupFormID, with: meetup_url
  #     click_on 'Submit'
  #     sleep 2
  #   end

  #   sleep 2

  #   # # TODO, VCR-ize and increase speed.
  #   # # Default selenium_chrome (vcr: true) is too slow.
  #   # VCR.use_cassette 'views/map/hover_map' do
  #   #   visit map_meetup_events_path
  #   #   # visit root_path
  #   #   INPUTS.each do |meetup_url:, **_|
  #   #     fill_in RSpecUtil::FormID, with: meetup_url
  #   #     click_on 'Submit'

  #   #     # This hack is here so that we won't have to hard wait (sleep x).
  #   #     # This will wait until the meetup_url entered will
  #   #     #   appear on the page. This is much quicker than sleep x.
  #   #     page.has_text? meetup_url, count: 1
  #   #   end
  #   # end
  # end

  # INPUTS.each do |meetup_url:, title:|
  #   context "when input is '#{meetup_url}'" do
  #     let(:xpath) { %{//div[@title="#{title}"]} }
  #     # Google changed this thing from area to div?
  #     # let(:xpath) { %{//area[@title="#{title}"]} }

  #     specify do
  #       within RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS do
  #         # Ideally, what I'd like is for this to auto wait but from
  #         #   observation it seems it finds the xpath, hover is executed,
  #         #   then recenters the map.
  #         #   But it happens so fast that's why the content is not found.
  #         #   Sleeping is the best band-aid for now.
  #         sleep 2

  #         # Hover or click, whatevs...
  #         page.find(:xpath, xpath).click
  #         # page.find(:xpath, xpath).hover
  #         expect(page).to have_content title
  #       end
  #     end
  #   end
  # end
end
