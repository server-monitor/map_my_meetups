
describe(
  'Behavior when event already exists in the database',
  js: true, selenium_chrome: true, vcr: false
) do
  pending 'might remove this, just make the current entry "bounce" instead' \
          ' of displaying an warning'
  # context 'when the same event link is entered more than once' do
  #   let(:input) do
  #     Struct.new(:link, :title).new(
  #       # Unique link because event ID/link clusterf**k.
  #       'https://www.meetup.com/SGVTech/events/xknvdlyvlbcb/',
  #       'PIC Programming, OpenSCAD, KiCad and All things Embedded'
  #     )
  #   end

  #   before do
  #     visit map_meetup_events_path

  #     3.times do
  #       fill_in RSpecUtil::MeetupFormID, with: input.link
  #       sleep 1
  #       click_on 'Submit'
  #       sleep 3
  #     end
  #     sleep 1
  #   end

  #   specify { expect(page).to have_content(/Event .*? already \s+ exists/x) }
  # end

  # context 'when the same group link is entered more than once' do
  #   let(:input) do
  #     Struct.new(:link, :title).new(
  #       RSpecUtil::OCRUBY_MEETUP_GROUP_URL,
  #       'PIC Programming, OpenSCAD, KiCad and All things Embedded'
  #     )
  #   end

  #   before do
  #     visit map_meetup_events_path

  #     3.times do
  #       fill_in RSpecUtil::MeetupFormID, with: input.link
  #       sleep 1
  #       click_on 'Submit'
  #       sleep 3
  #     end
  #     sleep 1
  #   end

  #   specify { expect(page).to have_content(/Event .*? already \s+ exists/x) }
  # end
end
