
shared_examples :create_action_post_create_call do
  describe 'post_create_call method' do
    specify 'should be defined' do
      expect(self).to respond_to :post_create_call
    end
  end
end

shared_examples :create_action_event_count_should_not_change do
  include_examples :create_action_post_create_call
  it 'should not change MeetupEvent count' do
    expect { post_create_call }.not_to change { MeetupEvent.count }
  end
end

shared_examples :create_action_event_count_should_change_by_1 do
  include_examples :create_action_post_create_call
  it 'should change MeetupEvent count' do
    expect { post_create_call }.to change { MeetupEvent.count }.by 1
  end
end

shared_examples :create_action_error do |danger = nil|
  describe 'error' do
    before { post_create_call }
    include_examples :create_action_post_create_call

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
