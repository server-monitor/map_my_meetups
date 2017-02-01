
describe 'Input validations', js: true, selenium_chrome: true, vcr: false do
  def submit(input)
    visit map_meetup_events_path

    fill_in RSpecUtil::MeetupFormID, with: input
    sleep 2
    click_on 'Submit'
    sleep 2
  end

  context(
    'when input link is a meetup group that has no next event' \
    ' (MAKE SURE THIS GROUP HAS NO EVENT, RELIES ON ACTUAL MEETUP.COM data)',
    vcr: false
  ) do
    before { submit RSpecUtil::MEETUP_GROUP_URL_WITH_NO_NEXT_EVENT }
    # before do
    #   visit map_meetup_events_path

    #   fill_in RSpecUtil::MeetupFormID,
    #           with: RSpecUtil::MEETUP_GROUP_URL_WITH_NO_NEXT_EVENT
    #   click_on 'Submit'
    #   sleep 2
    # end

    describe 'MeetupEvent count' do
      specify { expect(MeetupEvent.count).to eq 0 }
    end

    describe 'alert danger flash' do
      subject(:text) { page.find('.alert').text }
      it { should eq 'Group has no next event' }
    end
  end

  context(
    'when input link is a valid meetup that has no venue' \
    ' (MAKE SURE THIS EVENT HAS NO VENUE, RELIES ON ACTUAL MEETUP.COM data)',
    vcr: false
  ) do
    before { submit RSpecUtil::VALID_MEETUP_EVENT_WITH_NO_VENUE }

    # let(:post_create_no_venue) do
    #   VCR.use_cassette(
    #     'controllers/meetup_events/create_action/valid_event_with_no_venue'
    #   ) do
    #     post_create RSpecUtil::VALID_MEETUP_EVENT_WITH_NO_VENUE
    #   end
    # end

    pending <<-EOP
      TODO: DEBUG, invalid test, meetup events table doesn't get populated.
        Need to figure out how to why the datable doesn't refresh with new data.
    EOP

    # describe 'MeetupEvent count' do
    #   specify { expect(MeetupEvent.count).to eq 0 }
    # end

    describe 'alert danger flash' do
      subject(:text) { page.find('.alert').text }
      it { should eq 'Event has no venue' }
    end

    # it 'should not change MeetupEvent count' do
    #   expect { post_create_no_venue }.not_to change { MeetupEvent.count }
    # end

    # describe 'redirect' do
    #   before { post_create_no_venue }
    #   it { should set_flash[:error].to 'Event has no venue' }
    #   it { should redirect_to root_path }
    # end
  end

  context 'when search_input is valid', vcr: false do
    before { submit 'https://www.meetup.com/ocruby/' }

    # let(:post_create_valid_host) do
    #   VCR.use_cassette 'controllers/meetup_events/create_action' do
    #     post_create 'http://www.meetup.com/LA-Eastside-Ruby-Rails-Study-Group/'
    #   end
    # end
    # before { post_create_valid_host }

    pending <<-EOP
      TODO: DEBUG, meetup events table doesn't get populated.
        Need to figure out how to why the datable doesn't refresh with new data.
    EOP

    # describe 'MeetupEvent count' do
    #   specify { expect(MeetupEvent.count).to eq 1 }
    # end

    describe 'alert danger flash' do
      it { should_not have_css '.alert' }
      # subject(:text) { page.find('.alert').text }
      # it { should eq 'Event has no venue' }
    end

    # it 'should change MeetupEvent count by 1' do
    #   # post_create_valid_host
    #   sleep 1
    #   expect(MeetupEvent.count).to eq 1
    #   # sleep 2
    #   # expect { post_create_valid_host }
    #   #   .to change { MeetupEvent.count }.by(1)
    # end

    # describe 'redirect' do
    #   # before { post_create_valid_host }
    #   it { should_not redirect_to root_path }
    # end
  end
end
