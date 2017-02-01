
# require 'controllers/events'

require 'helpers/controllers/meetup_events'

class MeetupEventsController < ApplicationController
  # include MeetupEventsHelper
  before_action :user_uuid_get, only: [:map, :leaflet, :create]

  MEETUP_EVENT_IDS_KEY = :meetup_event_ids
  USER_UUID_KEY = :user_uuid

  private_constant :MEETUP_EVENT_IDS_KEY
  private_constant :USER_UUID_KEY

  # Hacks...
  def delete_all
    MeetupEvent.all.each do |meetup_event|
      vid = meetup_event.venue ? meetup_event.venue.id : nil
      Venue.find(vid).destroy if vid
    end

    MeetupEvent.delete_all
    redirect_to(root_path, flash: { danger: 'DELETED ALL meetup events' })

    cookies.delete(MEETUP_EVENT_IDS_KEY)

    # Prob. not a good idea to delete this.
    # cookies.delete(USER_UUID_KEY)
  end

  def leaflet
    @meetup_event = MeetupEvent.new
    js meetupEvents: meetup_events_as_json, railsEnv: Rails.env
  end
  # END hacks...

  def index
    @meetup_events = MeetupEvent.all
    @meetup_event = MeetupEvent.new
  end

  def map
    @meetup_event = MeetupEvent.new
    js meetupEvents: meetup_events_as_json, railsEnv: Rails.env
  end

  # POST /meetup_events
  # POST /meetup_events.json
  def create
    input_text = Meetup::InputText.new meetup_event_params[:input_text]
    return if errors? input_text

    user_id = current_user ? current_user.id : User::GUEST.id

    uri = input_text.validated_uri?

    if !uri
      # New design with open events API
      events_data_from_api = Meetup::API::GetOpenEvents.new.perform(
        input_text.to_s
      )
      return if errors? events_data_from_api

      events_data_from_api.with_valid_venue.each do |edfa|
        meetup_dot_com_id = edfa['id']

        meetup_event = MeetupEvent.find_by meetup_dot_com_id: meetup_dot_com_id

        if meetup_event
          ids_in_cookie_jar add: meetup_event.id
          next
        end

        venue_input = Meetup::ConvertAPIDataToParamFor::
                              VenueModel.new.perform(edfa['venue'])

        # TODO: DEBUG...
        next if venue_input.error
        venue = Venue.new venue_input.data

        event_input = Meetup::ConvertAPIDataToParamFor::
                              MeetupEventModel.new.perform(edfa)
        # TODO: DEBUG...
        next if event_input.error
        meetup_event = MeetupEvent.new(
          event_input.data.update(venue: venue, user_id: user_id)
        )

        meetup_event.save

        next if errors? meetup_event
        ids_in_cookie_jar add: meetup_event.id
      end

      # # Without sending to background job...
      # groups = Meetup::API::FindGroups.new.perform(input_text.to_s)

      # return if errors? groups
      # groups_with_next_event = groups.with_next_event

      # search_events = Meetup::SearchEvents.new.perform(
      #   groups_with_next_event, user_id
      # )

      # search_events.result.event_ids.each do |evid|
      #   ids_in_cookie_jar add: evid
      # end

      channel = "meetup_events_#{cookies[USER_UUID_KEY]}"
      bdata = {
        meetupEvents: meetup_events_as_json,
        railsEnv: Rails.env,
        referrer: referrer_get(request)
      }

      broadcast_to(channel, bdata)
      head :ok

      # SearchEventsJob.perform_later groups_with_next_event, user_id
      # head :ok

      # respond_to_wrapper
      return
    end

    event_data = Meetup::GetEventData.new.perform(input_text, uri)
    return if errors_or_exists? event_data

    meetup_event = Meetup::CreateEvent.new.perform(event_data, user_id)
    return if errors? meetup_event

    ids_in_cookie_jar add: meetup_event.id
    respond_to_wrapper
  end

  private

  include Helpers::Controllers::MeetupEvents

  def meetup_event_params
    params.permit(:input_text)
    # params.require(:meetup_event).permit(:input_text)
  end

  def default_redirect_fallback
    map_meetup_events_path
  end

  def errors_or_exists?(event_data)
    return true if errors? event_data
    return true if event_exists? event_data.data
  end

  def event_exists?(event_data_from_api)
    evid = event_data_from_api['id']
    event = MeetupEvent.find_by(meetup_dot_com_id: evid)
    if event
      Rails.logger.debug(
        "DEBUG ...: event '#{event.name}', ID '#{evid}' already exists"
      )

      ids_in_cookie_jar add: event.id
      return true
    end
  end

  def broadcast_to(channel, this_data)
    ActionCable.server.broadcast(channel, this_data)
  end

  def selected_events
    return MeetupEvent.where(user_id: current_user.id) if current_user
    return MeetupEvent.find(ids_in_cookie_jar)
  end

  def meetup_events_as_json
    selected_events.collect do |meetup_event|
      json = meetup_event.as_json
      json['venue'] = meetup_event.venue.as_json
      json['user'] = meetup_event.user.as_json
      json
    end
  end

  def ids_in_cookie_jar(add: nil)
    ids = \
      if  cookies[MEETUP_EVENT_IDS_KEY] and
          cookies[MEETUP_EVENT_IDS_KEY] != 'undefined'
        ActiveSupport::JSON.decode(cookies[MEETUP_EVENT_IDS_KEY])
      else
        []
      end

    return ids if !add

    ids.delete add
    ids.push add

    cookies[MEETUP_EVENT_IDS_KEY] = ids.to_json
  end

  def user_uuid_get
    return @user_uuid if @user_uuid

    user_uuid = cookies[USER_UUID_KEY]

    if !user_uuid
      user_uuid = 'user_'
      user_uuid << (current_user ? current_user.id : User::GUEST.id).to_s
      user_uuid << '_' << SecureRandom.uuid.to_s
      cookies[USER_UUID_KEY] = user_uuid
    end

    @user_uuid = user_uuid
    return user_uuid
  end

  def referrer_get(request)
    default = 'map'
    referer = request.referer
    return default if !referer
    pcomps = referer.split('/')
    return default if pcomps.empty?
    last = pcomps.last
    return default if last.strip.empty?
    return last
  end
end
