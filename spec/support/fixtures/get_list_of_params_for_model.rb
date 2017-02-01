
module Fixture
  module GetListOfParamsForModel
    class << self
      def res_body_of(event_unique_name)
        file = File.join(
          File.dirname(__FILE__), 'json', event_unique_name + '.json'
        )

        JSON.parse File.read file
      end
    end
  end
end
