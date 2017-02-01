
require 'json'

require_relative './constant'

module Meetup
  module Base
    include Meetup::Constant

    ENCODED_API_KEY = URI.encode_www_form(
      key: ENV.fetch('MEETUP_API_KEY')
    ).freeze

    private_constant :ENCODED_API_KEY

    def error
      @error
    end

    def error_set(msg)
      @error = msg
    end

    # TODO: DEBUG, not tested...
    def event?(path)
      if path =~ %r{\A / [^\/]+ / events / ([^\/]+) /? \z}x
        return Regexp.last_match(1)
      end
    end

    private

    def convert_to_api_url(url)
      url.sub(/www[.]/, 'api.')
    end

    def query_get(uri)
      uri.query ? (uri.query + '&' << ENCODED_API_KEY) : ENCODED_API_KEY
    end

    def json_get(res)
      body = res.body
      return body ? JSON.parse(body) : nil
    end

    def valid_host!(host)
      if !valid_host?(host)
        error_set 'HTTP input host is not one of: ' << valid_hosts_string
        return
      end
      return true
    end

    def valid_host?(host)
      Meetup::Constant::VALID_HOSTS.include? host
    end

    def valid_hosts_string
      Meetup::Constant::VALID_HOSTS.sort.join(', ')
    end

    def not_ok!(res)
      if !res.is_a? Net::HTTPOK
        error_set "Response, #{res}, is not Net::HTTPOK"
        return true
      end
    end

    def not_hash!(data, prepend_msg: '')
      return if data.is_a? Hash
      prepend_msg += ' ' if !prepend_msg.strip.empty?
      error_set prepend_msg + "'#{data}' is not a hash"
      return true
    end

    def change_keys_to_match_model_params(conversion_table, input_data)
      return conversion_table.reduce(
        {}
      ) do |memo, (model_attr_name, key_used_by_input_data)|
        key_used_by_input_data ||= model_attr_name.to_s
        memo.merge(model_attr_name => input_data[key_used_by_input_data])
      end
    end

    module Venue
      COORD_FOR = { lat: 'lat(itude)', lon: 'lon(gitude)' }.freeze

      private_constant :COORD_FOR

      def no_coord!(type, venue, err_msg: nil)
        msg = COORD_FOR[type]
        raise "Invalid coord key '#{type}', valid types: #{COORD_FOR}" if !msg

        coord_value = venue[type.to_s]
        return if coord_value
        err_msg ||= "Venue has no #{msg}"
        error_set err_msg
        return true
      end
    end
  end
end
