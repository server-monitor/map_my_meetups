
class ApiRequestJob < ApplicationJob
  queue_as :default

  rescue_from Exception do |exception|
    [
      '!!ERROR, RESCUED FROM ActiveJob' << to_s + '...!!',
      exception.inspect,
      exception.backtrace.join("\n"),
      '!!END RESCUE!!'
    ].each { |msg| Rails.logger.error msg }
    raise
  end

  def perform(search_input, user_id, user_uuid, *ids_in_cookie_jar)
    event_id = nil
    MeetupEvent.pluck(:id, :link).each do |id, link|
      if ComparisonHelper.url(search_input, link)
        event_id = id
        break
      end
    end

    meetup_event = MeetupEvent.find_by(id: event_id)

    if !meetup_event
      meetup_event = MeetupEvent.new
      meetup_event.search_input = search_input
      meetup_event.user_id = user_id
      meetup_event.save
    end

    errors = meetup_event.errors
    base_errors = errors[:base]

    broadcast_data = \
      if base_errors.count > 0
        event = meetup_events.event_exists?

        if event
          ids_in_cookie_jar.delete event.id \
            if ids_in_cookie_jar.include?(event.id)

          ids_in_cookie_jar.push event.id
          pp ids_in_cookie_jar: ids_in_cookie_jar

          {
            meetupEvents: meetup_events_as_json(ids_in_cookie_jar),
            idsInCookieJar: ids_in_cookie_jar.as_json,
            # newEvent: nil,
            railsEnv: Rails.env
          }
        else
          {
            errors: base_errors.as_json
          }
        end
      elsif errors.count > 0
        {
          errors: errors.as_json
        }
      else
        ids_in_cookie_jar.delete meetup_event.id \
          if ids_in_cookie_jar.include?(meetup_event.id)

        ids_in_cookie_jar.push meetup_event.id
        pp ids_in_cookie_jar: ids_in_cookie_jar, id: meetup_event.id
        {
          meetupEvents: meetup_events_as_json(ids_in_cookie_jar),
          idsInCookieJar: ids_in_cookie_jar.as_json,
          # newEvent: nil,
          railsEnv: Rails.env
        }
      end

    ActionCable.server.broadcast(
      "meetup_events_#{user_uuid}", broadcast_data
    )
  end

  private

  def meetup_events_as_json(ids_in_cookie_jar)
    MeetupEvent.find(ids_in_cookie_jar).collect do |meetup_event|
      json = meetup_event.as_json
      json['venue'] = meetup_event.venue.as_json
      json['user'] = meetup_event.user.as_json
      json
    end
  end
end
