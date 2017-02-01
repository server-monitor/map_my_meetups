
require 'uri'

module ComparisonHelper
  class << self
    VALID_CLASSES = [URI::HTTP, URI::HTTPS].freeze

    def url(u1, u2)
      uri1, uri2 = validate_urls(u1, u2)

      return if uri1.scheme.sub(/ s \z/x, '') != uri2.scheme.sub(/ s \z/x, '')
      return if uri1.host != uri2.host
      return if uri1.path.sub(%r{ / \z}x, '') != uri2.path.sub(%r{ / \z}x, '')
      return true
    end

    def validate_urls(u1, u2)
      uri1 = URI u1
      uri2 = URI u2

      if  !uri1.scheme or !uri2.scheme or
          !VALID_CLASSES.include?(uri1.class) or
          !VALID_CLASSES.include?(uri2.class)
        raise "One or both URL params, '#{u1}' & '#{u2}', is/are not HTTP(s)"
      end
      return uri1, uri2
    end
  end
end
