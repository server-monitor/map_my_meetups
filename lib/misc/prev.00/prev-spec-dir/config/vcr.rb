
require 'vcr'

VCR.configure do |vcr|
  vcr.cassette_library_dir = Rails.root.join('spec', 'fixtures', 'vcr')

  vcr.filter_sensitive_data '<GOOGLE_API_KEY>' do
    ENV.fetch 'GOOGLE_API_KEY'
  end

  vcr.filter_sensitive_data '<MAPZEN_SEARCH_API_KEY>' do
    ENV.fetch 'MAPZEN_SEARCH_API_KEY'
  end

  vcr.filter_sensitive_data '<MEETUP_API_KEY>' do
    ENV.fetch 'MEETUP_API_KEY'
  end

  vcr.hook_into :webmock

  # Probably the safest thing to do.
  # Also will likely give us more robust tests
  #   instead of ignore_request ...
  # vcr.ignore_request do |request|
  #   uri = URI(request.uri)
  #   # Chrome driver shutdown http://127.0.0.1:9515/shutdown
  #   uri.host == '127.0.0.1' && uri.port == 9515
  # end
  vcr.ignore_localhost = true
end

RSpec.configure do |config|
  config.around :each, vcr: false do |example|
    WebMock.allow_net_connect!
    VCR.turned_off { example.run }
    WebMock.disable_net_connect!
  end
end
