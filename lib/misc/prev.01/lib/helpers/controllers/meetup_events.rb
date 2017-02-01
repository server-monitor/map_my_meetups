
module Helpers
  module Controllers
    module MeetupEvents
      # This hack exists because respond_to? doesn't detect this method.
      def default_redirect_fallback
        nil
      end

      def respond_to_wrapper(fallback_location: nil, options: {})
        # This hack exists because respond_to? doesn't detect this method.
        fallback_location ||= default_redirect_fallback || root_path

        respond_to do |format|
          format.js do
            redirect_back options.merge(fallback_location: fallback_location)
          end
          # format.js { render :error, errors: meetup_event.error }
        end
      end

      def errors?(object, fallback_location: nil)
        error_messages = nil

        if object.is_a?(ApplicationRecord)
          errors = object.errors
          return if errors.count == 0
          error_messages = errors.full_messages.join(', ')
        else
          error = object.error
          return if !error
          error_messages = error
        end

        respond_to_wrapper fallback_location: fallback_location,
                           options: { flash: { danger: error_messages } }

        return true
      end
    end
  end
end
