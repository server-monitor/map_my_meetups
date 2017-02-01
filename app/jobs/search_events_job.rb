
# class SearchEventsJob < ApplicationJob
#   queue_as :default

#   MEETUP_EVENT_IDS_KEY = :meetup_event_ids
#   USER_UUID_KEY = :user_uuid

#   private_constant :MEETUP_EVENT_IDS_KEY
#   private_constant :USER_UUID_KEY

#   rescue_from Exception do |exception|
#     [
#       '!!ERROR, RESCUED FROM ActiveJob' << to_s + '...!!',
#       exception.inspect,
#       exception.backtrace.join("\n"),
#       '!!END RESCUE!!'
#     ].each { |msg| Rails.logger.error msg }
#     raise
#   end

#   def perform(text_to_search, user_id)
#     search_events = Meetup::SearchEvents.new.perform(text_to_search, user_id)
#     search_events.result.event_ids.each do |evid|
#       ids_in_cookie_jar add: evid
#     end

#     channel = "meetup_events_#{cookies[USER_UUID_KEY]}"
#     bdata = {
#       meetupEvents: meetup_events_as_json,
#       railsEnv: Rails.env,
#       referrer: request.referer.split('/').last
#     }

#     broadcast_to(channel, bdata)
#   end

#   private

#   def broadcast_to(channel, this_data)
#     ActionCable.server.broadcast(channel, this_data)
#   end

#   def selected_events
#     return MeetupEvent.where(user_id: current_user.id) if current_user
#     return MeetupEvent.find(ids_in_cookie_jar)
#   end

#   def meetup_events_as_json
#     selected_events.collect do |meetup_event|
#       json = meetup_event.as_json
#       json['venue'] = meetup_event.venue.as_json
#       json['user'] = meetup_event.user.as_json
#       json
#     end
#   end

#   def ids_in_cookie_jar(add: nil)
#     ids = \
#       if  cookies[MEETUP_EVENT_IDS_KEY] and
#           cookies[MEETUP_EVENT_IDS_KEY] != 'undefined'
#         ActiveSupport::JSON.decode(cookies[MEETUP_EVENT_IDS_KEY])
#       else
#         []
#       end

#     return ids if !add

#     ids.delete add
#     ids.push add

#     cookies[MEETUP_EVENT_IDS_KEY] = ids.to_json
#   end
# end
