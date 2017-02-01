
module Meetup
  module Constant
    MEETUP_DOT_COM = 'meetup.com'.freeze
    WWW_MEETUP_DOT_COM = ('www.' << MEETUP_DOT_COM).freeze
    API_MEETUP_DOT_COM = ('api.' << MEETUP_DOT_COM).freeze

    VALID_HOSTS = [API_MEETUP_DOT_COM, WWW_MEETUP_DOT_COM].freeze
  end
end
