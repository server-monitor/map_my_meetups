
require 'webmock/rspec'
require 'uri'

def setup_api_stub_request(url: nil, status: 200, body: '')
  url ||= stubbed_url || raise('Must pass URL or define method "stubbed_url"')
  url.blank? and raise 'URL should not be blank'

  uri = URI url.sub(/www[.]/, 'api.')
  uri.query = uri.query ? (uri.query + '&' + ENCODED_API_KEY) : ENCODED_API_KEY

  stub_request(:get, uri).with(
    headers: {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => 'api.meetup.com',
      'User-Agent' => 'Ruby'
    }
  ).to_return(status: status, body: body, headers: {})
end
