
require 'json'

module Fixture
  module Events
    class << self
      def by_url(url)
        urlname = url.sub(%r{ \A .+ [.]com /}x, '')
                     .sub(%r{ /events .+ \z }x, '')
        event_id = url.sub(%r{ \A .+ events /}x, '')
                      .sub(/ [\?] .+ \z /x, '')

        JSON.parse(
          File.read(File.join(json_dir, urlname + '_' + event_id + '.json'))
        )
      end

      private

      def json_dir
        File.join __dir__, File.basename(__FILE__, '.rb')
      end
    end
  end
end
