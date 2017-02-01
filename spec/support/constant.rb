
module RSpecUtil
  MeetupFormID = 'input_text'.freeze
  GOOGLE_PROVIDED_MAP_CLASS = '.gm-style'.freeze

  MEETUP_DOT_COM_DOMAIN = 'meetup.com'.freeze
  HTTPS_MEETUP_DOT_COM_DOMAIN = ('https://' << MEETUP_DOT_COM_DOMAIN).freeze

  WWW_MEETUP_DOT_COM = ('www.' << MEETUP_DOT_COM_DOMAIN).freeze
  API_MEETUP_DOT_COM = ('api.' << MEETUP_DOT_COM_DOMAIN).freeze
  HTTPS_API = ('https://' + API_MEETUP_DOT_COM).freeze

  VALID_HOSTS = [API_MEETUP_DOT_COM, WWW_MEETUP_DOT_COM].freeze
  VALID_HOSTS_STRING = VALID_HOSTS.join(', ').freeze

  HTTPS_MEETUP_DOT_COM = ('https://' << WWW_MEETUP_DOT_COM).freeze
  HTTP_MEETUP_DOT_COM = ('http://' << WWW_MEETUP_DOT_COM).freeze

  OCRUBY_GROUP_URL = [HTTPS_MEETUP_DOT_COM, '/ocruby'].join.freeze
  OCRUBY_EVENT_URL_ID = '232799633'.freeze
  OCRUBY_EVENT_URL = (
    OCRUBY_GROUP_URL + '/events/' << OCRUBY_EVENT_URL_ID
  ).freeze

  OCRUBY_EVENT = {
    # Transient...
    time: 1_472_176_800_000,
    meetup_dot_com_id: 'npbsclyvlbhc',
    link: 'http://www.meetup.com/ocruby/events/232799633',
    name: 'Orange County Ruby Users Group (OCRuby) Meetup',

    # Prob. permanent forever. TODO, DEBUG: turn to integer.
    utc_offset: -25_200_000.to_s
  }.freeze

  OCRUBY_EVENT_VENUE = {
    venue_id: 21_898_262,
    name: 'Eureka Bldg',
    latitude: 33.69908142089844,
    longitude: -117.84720611572266,
    repinned: false,
    address: '1621 Alton Parkway',
    city: 'Irvine',
    country: 'us',
    # localized_country_name: 'USA',
    zip: nil,
    state: 'CA'

    # # With corresponding meetup.com API data keys...
    # venue_id: { id: 21_898_262 },
    # name: 'Eureka Bldg',
    # latitude: { lat: 33.69908142089844 },
    # longitude: { lon: -117.84720611572266 },
    # repinned: false,
    # address: { address_1: '1621 Alton Parkway' },
    # city: 'Irvine',
    # country: 'us',
    # # localized_country_name: 'USA',
    # zip: nil,
    # state: 'CA'
  }.freeze

  GROUP_WITHOUT_NEXT_EVENT = 'https://www.meetup.com/AWS-Pasadena-Official-Events'.freeze

  NOT_MEETUP_DOT_COM = 'https://www.msn.com/'.freeze
  NOT_A_URL = 'not-a-url'.freeze
  TEXT_WITH_SPACE = 'text with space'.freeze
end
