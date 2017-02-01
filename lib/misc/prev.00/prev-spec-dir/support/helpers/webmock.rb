
require 'webmock/rspec'

def setup_api_stub_request(url: nil, status: 200, body: '')
  url ||= stubbed_url
  url.blank? and raise 'URL should not be blank'

  stub_request(
    :get, url.sub(/www[.]/, 'api.') + '?key=' << ENV.fetch('MEETUP_API_KEY')
  ).with(
    headers: {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => 'api.meetup.com',
      'User-Agent' => 'Ruby'
    }
  ).to_return(status: status, body: body, headers: {})
end
