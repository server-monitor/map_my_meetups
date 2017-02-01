
shared_examples :event_count_should_be_zero do
  describe 'event count' do
    specify { expect(MeetupEvent.count).to eq 0 }
  end
end

shared_examples :event_count_should_eq_1 do
  describe 'event count' do
    specify { expect(MeetupEvent.count).to eq 1 }
  end
end

shared_examples :input_validations_error do |danger = nil|
  describe 'error' do
    if danger
      describe 'page' do
        subject { page }
        it { should have_css '.alert-danger', text: danger, count: 1 }
      end

      # describe 'redirect' do
      #   it { should redirect_to map_meetup_events_path }
      # end
    else
      it { should_not have_css '.alert' }
    end
  end
end
