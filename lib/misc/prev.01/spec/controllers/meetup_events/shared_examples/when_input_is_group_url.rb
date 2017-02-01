
shared_examples :when_input_is_group_url do
  context 'when input is group url' do
    let(:stubbed_url) { GROUP_WITHOUT_NEXT_EVENT }

    context 'when group has no next event' do
      let(:post_create_call) do
        setup_api_stub_request
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :create_action_event_count_should_not_change
      include_examples :create_action_error, 'Group has no next event'
    end

    context 'when next event has no event id' do
      let(:post_create_call) do
        setup_api_stub_request body: next_event_without_id.to_json
        VCR.turned_off { post_create stubbed_url }
      end

      include_examples :create_action_event_count_should_not_change
      include_examples :create_action_error, 'Event has no ID'
    end

    context 'when group input is valid' do
      let(:post_create_call) do
        # Verified same data by looking URLs up on meetup.com
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

      include_examples :create_action_error
    end
  end
end
