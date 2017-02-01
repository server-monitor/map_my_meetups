
require 'net/http'
require 'uri'

module Meetup
  module API
    module Base
      ENCODED_API_KEY = URI.encode_www_form(
        key: ENV.fetch('MEETUP_API_KEY')
      ).freeze

      private_constant :ENCODED_API_KEY

      private

      def convert_to_api_url(url)
        url.sub(%r{ http:// }x, 'https://').sub(/www[.]/, 'api.')
      end

      def not_ok!(res)
        if !res.is_a? Net::HTTPOK
          error_set "Response, #{res}, is not Net::HTTPOK"
          return true
        end
      end

      def get_response(uri)
        uri.query = query_get(uri)
        Net::HTTP.get_response uri
      end

      def query_get(uri)
        uri.query ? (uri.query + '&' + ENCODED_API_KEY) : ENCODED_API_KEY
      end

      def event_uri_get(group_url, event_id)
        api_url = convert_to_api_url group_url
        URI(URI.join(api_url.sub(%r{ /* \z}x, '/'), 'events/', event_id))
      end

      class << self
        def uri_for_search_api_ep(uri, text_to_search, query_table)
          uri.query = URI.encode_www_form(sign: true)

          query_table.merge(text: text_to_search).sort.each do |qkey, qparam|
            # https://stackoverflow.com/questions/16623421/ruby-how-to-add-a-param-to-an-url-that-you-dont-know-if-it-has-any-other-param
            ar = URI.decode_www_form(uri.query) << [qkey, qparam]
            uri.query = URI.encode_www_form(ar)
          end

          return uri
        end
      end
    end
  end
end
