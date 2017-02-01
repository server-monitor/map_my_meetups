
require 'support/helpers/webmock'
require 'support/helpers/fixtures'

require 'support/constant'
include RSpecUtil

require_relative 'support/create_action'
require_relative 'shared_examples/create_action'
require_relative 'shared_examples/when_input_is_event_url'
require_relative 'shared_examples/when_input_is_group_url'
require_relative 'shared_examples/when_input_is_keyword_to_search'

describe MeetupEventsController do
  context 'when input text is blank' do
    let(:post_create_call) { post_create }

    include_examples :create_action_event_count_should_not_change
    include_examples :create_action_error,
                     'Must enter meetup group, event or keyword to search'
  end

  context 'when input text is ' << TEXT_WITH_SPACE do
    let(:post_create_call) { post_create TEXT_WITH_SPACE }
    include_examples :create_action_event_count_should_not_change
    include_examples :create_action_error,
                     'Space is an invalid character (TODO)'
  end

  context 'when input is not meetup.com' do
    let(:post_create_call) { post_create NOT_MEETUP_DOT_COM }
    include_examples :create_action_event_count_should_not_change
    include_examples :create_action_error,
                     'HTTP input host is not one of: ' << VALID_HOSTS_STRING
  end

  context 'when response is not ok' do
    let(:stubbed_url) { OCRUBY_EVENT_URL }
    let(:post_create_call) do
      setup_api_stub_request status: 400
      VCR.turned_off { post_create stubbed_url }
    end

    include_examples :create_action_event_count_should_not_change
    include_examples :create_action_error,
                     /Response .+? is \s+ not \s+ Net::HTTPOK/x
  end

  include_examples :when_input_is_event_url
  include_examples :when_input_is_group_url
  include_examples :when_input_is_keyword_to_search
end
