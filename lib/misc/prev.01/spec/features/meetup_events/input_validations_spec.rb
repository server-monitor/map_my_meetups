
require 'support/helpers/webmock'
require 'support/helpers/fixtures'

require 'support/constant'
include RSpecUtil

require_relative 'support/input_validations'
require_relative 'shared_examples/input_validations'
require_relative 'shared_examples/when_input_is_event_url'
require_relative 'shared_examples/when_input_is_group_url'

describe 'Input validations', js: true, selenium_chrome: true, vcr: false do
  context 'when input text is blank' do
    before { submit }
    include_examples :event_count_should_be_zero
    include_examples :input_validations_error,
                     'Must enter meetup group, event or keyword to search'
  end

  context 'when input text is ' << TEXT_WITH_SPACE do
    before { submit TEXT_WITH_SPACE }
    include_examples :event_count_should_be_zero
    include_examples :input_validations_error,
                     'Space is an invalid character (TODO)'
  end

  context 'when input is not meetup.com' do
    before { submit NOT_MEETUP_DOT_COM }
    include_examples :event_count_should_be_zero
    include_examples :input_validations_error,
                     'HTTP input host is not one of: ' << VALID_HOSTS_STRING
  end

  context 'when response is not ok' do
    before do
      setup_api_stub_request url: OCRUBY_EVENT_URL, status: 400
      submit OCRUBY_EVENT_URL
    end

    include_examples :event_count_should_be_zero
    include_examples :input_validations_error,
                     /Response .+? is \s+ not \s+ Net::HTTPOK/x
  end

  include_examples :input_validations_when_input_is_event_url
  include_examples :input_validations_when_input_is_group_url
end
