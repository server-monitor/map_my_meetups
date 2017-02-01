
module RSpecUtil
  # FormID = 'geo_marker_host'.freeze
  MeetupFormID = 'input_text'.freeze
  GOOGLE_PROVIDED_MAP_CLASS = '.gm-style'.freeze

  # NOT_MEETUP_DOT_COM_ERROR_MSG_REGEXP = Regexp.new(
  #   /host \s+ not \s+ '\(www[.]\)meetup[.]com'/x
  # ).freeze

  MEETUP_DOT_COM_DOMAIN = 'meetup.com'.freeze
  HTTPS_MEETUP_DOT_COM_DOMAIN = ('https://' << MEETUP_DOT_COM_DOMAIN).freeze

  WWW_MEETUP_DOT_COM = ('www.' << MEETUP_DOT_COM_DOMAIN).freeze
  API_MEETUP_DOT_COM = ('api.' << MEETUP_DOT_COM_DOMAIN).freeze

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

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #

# module RSpecUtil
#   FormID = 'geo_marker_host'.freeze
#   MeetupFormID = 'meetup_event_search_input'.freeze
#   GOOGLE_PROVIDED_MAP_CLASS = '.gm-style'.freeze

#   NOT_MEETUP_DOT_COM_ERROR_MSG_REGEXP = Regexp.new(
#     /host \s+ not \s+ '\(www[.]\)meetup[.]com'/x
#   ).freeze

#   MEETUP_DOT_COM_DOMAIN = 'meetup.com/'.freeze
#   HTTPS_MEETUP_DOT_COM_DOMAIN = ('https://' << MEETUP_DOT_COM_DOMAIN).freeze

#   MEETUP_DOT_COM = ('www.' << MEETUP_DOT_COM_DOMAIN).freeze
#   HTTPS_MEETUP_DOT_COM = ('https://' << MEETUP_DOT_COM).freeze
#   OCRUBY_MEETUP_GROUP_URL = [HTTPS_MEETUP_DOT_COM, 'ocruby/'].join.freeze

#   # Event ID, will probably disappear some time in the future.
#   OCRUBY_EVENT_EVENT_ID = (ENV['EVENTID'] || '232306607').freeze.to_i
#   OCRUBY_EVENT = [
#     OCRUBY_MEETUP_GROUP_URL, 'events/', OCRUBY_EVENT_EVENT_ID, '/'
#   ].join.freeze
#   # https://www.meetup.com/ocruby/events/232306607/

#   # TODO, DEBUG: WebMock-ize these instead of relying on actual meetup.com.
#   MEETUP_GROUP_URL_WITH_NO_NEXT_EVENT = 'https://www.meetup.com/AWS-Pasadena-Official-Events'.freeze
#   VALID_MEETUP_EVENT_WITH_NO_VENUE = 'https://www.meetup.com/LA-Software-Workshops/events/232713877'.freeze

#   # ... with expected values
#   VENUE_ATTRIBUTES = {
#     venue_id: 21_898_262,

#     # Clus...
#     # name: 'Eureka Bldg',

#     latitude: 33.69908142089844,
#     longitude: -117.84720611572266,
#     repinned: false,
#     address: '1621 Alton Parkway',
#     city: 'Irvine',
#     country: 'us',
#     # localized_country_name: 'USA',
#     zip: nil,
#     state: 'CA'

#     # venue_id: { id: 21_898_262 },
#     # name: 'Eureka Bldg',
#     # latitude: { lat: 33.69908142089844 },
#     # longitude: { lon: -117.84720611572266 },
#     # repinned: false,
#     # address: { address_1: '1621 Alton Parkway' },
#     # city: 'Irvine',
#     # country: 'us',
#     # # localized_country_name: 'USA',
#     # zip: nil,
#     # state: 'CA'
#   }.freeze
# end
