
shared_examples :input_validations_when_input_is_group_url do
  context 'when input is group url' do
    let(:stubbed_url) { GROUP_WITHOUT_NEXT_EVENT }

    context 'when group has no next event' do
      before do
        setup_api_stub_request
        submit stubbed_url
      end

      include_examples :event_count_should_be_zero
      include_examples :input_validations_error, 'Group has no next event'
    end

    context 'when next event has no event id' do
      before do
        setup_api_stub_request body: next_event_without_id.to_json
        submit stubbed_url
      end

      include_examples :event_count_should_be_zero
      include_examples :input_validations_error, 'Event has no ID'
    end

    context 'when group input is valid' do
      before do
        # Verified same data by looking up URLs on meetup.com
        hack_different_id_but_same_data = OCRUBY_EVENT_URL.sub(
          '232799633', 'npbsclyvlbhc'
        )
        setup_api_stub_request url: hack_different_id_but_same_data,
                               body: event_data_from_api.to_json
        setup_api_stub_request url: OCRUBY_GROUP_URL,
                               body: OCRUBY_GROUP_RES_BODY.to_json

        submit OCRUBY_GROUP_URL
      end

      include_examples :event_count_should_eq_1
      include_examples :input_validations_error
    end
  end
end
