
require 'uri'

require_relative './base'

module Meetup
  class InputText
    include Meetup::Base

    def initialize(input_input)
      if input_input.blank?
        error_set 'Must enter meetup group, event or keyword to search'
        return
      end

      if space?(input_input)
        error_set 'Space is an invalid character (TODO)'
        return
      end

      non_validated_uri = URI input_input

      if http?(non_validated_uri)
        @uri = validate non_validated_uri
        return if error
      end

      @input = input_input
    end

    def validated_uri?
      assert_no_error!
      uri
    end

    def event?
      assert_no_error!
      validated_uri? or raise "This '#{input}' should be a validated URI"
      super(uri.path)
    end

    def to_s
      input
    end

    private

    attr_reader :input, :uri

    def space?(string)
      string =~ /\s/
    end

    def assert_no_error!
      raise "Error '#{error}' present" if error
    end

    def http?(uri)
      return true if uri.is_a?(URI::HTTP)
    end

    def validate(non_validated_uri)
      if !valid_host? non_validated_uri.host
        error_set 'HTTP input host is not one of: ' << valid_hosts_string
        return
      end

      return non_validated_uri
    end
  end
end
