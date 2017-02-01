
# require 'controllers/events'

require 'helpers/controllers/meetup_events'

class MeetupEventsController < ApplicationController
  # include MeetupEventsHelper
  before_action :user_uuid_get, only: [:map, :leaflet, :create]

  MEETUP_EVENT_IDS_KEY = :meetup_event_ids
  USER_UUID_KEY = :user_uuid

  private_constant :MEETUP_EVENT_IDS_KEY, :USER_UUID_KEY
  # private_constant :USER_UUID_KEY

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

    # user_id = current_user ? current_user.id : User::GUEST.id

    uri = input_text.validated_uri?

    # NEW NEW
    events_data_from_api = \
      if uri
        Meetup::GetOneEventDataUsingURI.new.perform(input_text, uri)
      else
        Meetup::GetMultipleEventsUsingSearchWord.new.perform(input_text.to_s)
        # Meetup::API::GetOpenEvents.new.perform(input_text.to_s)
      end

    with_valid_venue = events_data_from_api.with_valid_venue
    single = with_valid_venue == 1

    ix = 0
    loop do
      edfa = with_valid_venue[ix]
      break if !edfa
      ix += 1

      next if event_exists? edfa

      # meetup_dot_com_id = edfa['id']

      # meetup_event = MeetupEvent.find_by meetup_dot_com_id: meetup_dot_com_id

      # if meetup_event
      #   to_cookie_jar_add meetup_event.id
      #   next
      # end

      meetup_event = Meetup::CreateMeetupEvent.new.perform(edfa, user_id)
      if errors? meetup_event
        return if single
        next
      end

      # venue_input = Meetup::ConvertAPIDataToParamFor::
      #                       VenueModel.new.perform(edfa['venue'])

      # # TODO: DEBUG, next or warn?
      # # Ideally some kind of unobtrusive pop-up that shows the error.
      # if errors? venue_input
      #   break if single
      #   next
      # end
      # # next if venue_input.error
      # venue = Venue.new venue_input.data

      # event_input = Meetup::ConvertAPIDataToParamFor::
      #                       MeetupEventModel.new.perform(edfa)

      # # TODO: DEBUG, next or warn?
      # # next if event_input.error
      # if errors? event_input
      #   break if single
      #   next
      # end

      # meetup_event = MeetupEvent.new(
      #   event_input.data.update(venue: venue, user_id: user_id)
      # )

      # meetup_event.save
      # # TODO: DEBUG, next or warn?
      # # next if errors? meetup_event
      # if errors? meetup_event
      #   break if single
      #   next
      # end

      to_cookie_jar_add meetup_event.id
    end

    if single
      respond_to_wrapper
      return
    end

    cable_broadcast
    # CableBroadcast.new.perform(
    #   channel: "meetup_events_#{cookies[USER_UUID_KEY]}",
    #   data: {
    #     meetupEvents: meetup_events_as_json,
    #     railsEnv: Rails.env,
    #     referrer: referrer_get(request)
    #   }
    # )

    head :ok

    # respond_to_wrapper
    # NEW NEW

    # # PREV
    # if !uri
    #   # New design with open events API
    #   events_data_from_api = Meetup::API::GetOpenEvents.new.perform(
    #     input_text.to_s
    #   )
    #   return if errors? events_data_from_api

    #   events_data_from_api.with_valid_venue.each do |edfa|
    #     meetup_dot_com_id = edfa['id']

    #     meetup_event = MeetupEvent.find_by meetup_dot_com_id: meetup_dot_com_id

    #     if meetup_event
    #       to_cookie_jar_add meetup_event.id
    #       next
    #     end

    #     venue_input = Meetup::ConvertAPIDataToParamFor::
    #                           VenueModel.new.perform(edfa['venue'])

    #     # TODO: DEBUG, next or warn?
    #     # Ideally some kind of unobtrusive pop-up that shows the error.
    #     next if venue_input.error
    #     venue = Venue.new venue_input.data

    #     event_input = Meetup::ConvertAPIDataToParamFor::
    #                           MeetupEventModel.new.perform(edfa)

    #     # TODO: DEBUG, next or warn?
    #     next if event_input.error
    #     meetup_event = MeetupEvent.new(
    #       event_input.data.update(venue: venue, user_id: user_id)
    #     )

    #     meetup_event.save
    #     next if errors? meetup_event

    #     to_cookie_jar_add meetup_event.id
    #   end

    #   CableBroadcast.new.perform(
    #     channel: "meetup_events_#{cookies[USER_UUID_KEY]}",
    #     data: {
    #       meetupEvents: meetup_events_as_json,
    #       railsEnv: Rails.env,
    #       referrer: referrer_get(request)
    #     }
    #   )

    #   head :ok

    #   # respond_to_wrapper
    #   return
    # end

    # event_data = Meetup::GetEventData.new.perform(input_text, uri)
    # return if errors? event_data
    # event = event_exists? event_data.data
    # if event
    #   to_cookie_jar_add event.id
    #   return
    # end
    # # return if errors_or_exists? event_data

    # meetup_event = Meetup::CreateEvent.new.perform(event_data, user_id)
    # return if errors? meetup_event

    # to_cookie_jar_add meetup_event.id
    # respond_to_wrapper
  end

  private

  include Helpers::Controllers::MeetupEvents

  def meetup_event_params
    params.permit(:input_text)
  end

  def default_redirect_fallback
    map_meetup_events_path
  end

  def user_id
    current_user ? current_user.id : User::GUEST.id
  end

  # def errors_or_exists?(event_data)
  #   return true if errors? event_data
  #   return true if event_exists? event_data.data
  # end

  # def event_exists?(event_data_from_api)
  #   evid = event_data_from_api['id']
  #   event = MeetupEvent.find_by(meetup_dot_com_id: evid)
  #   if event
  #     Rails.logger.debug(
  #       "DEBUG ...: event '#{event.name}', ID '#{evid}' already exists"
  #     )

  #     to_cookie_jar_add event.id
  #     return true
  #   end
  # end

  def to_cookie_jar_add(event_id)
    cookies[MEETUP_EVENT_IDS_KEY] = ids_in_cookie_jar(
      cookies[MEETUP_EVENT_IDS_KEY], add: event_id
    )
  end

  def meetup_events_as_json
    meetup_events_as_json_helper(
      ids_in_cookie_jar(cookies[MEETUP_EVENT_IDS_KEY]), current_user
    )
  end

  def user_uuid_get
    return @user_uuid if @user_uuid

    user_uuid = cookies[USER_UUID_KEY]

    if !user_uuid
      user_uuid = 'user_' + user_id.to_s + '_' + SecureRandom.uuid.to_s
      cookies[USER_UUID_KEY] = user_uuid
    end

    @user_uuid = user_uuid
    return user_uuid
  end

  def cable_broadcast
    CableBroadcast.new.perform(
      channel: "meetup_events_#{cookies[USER_UUID_KEY]}",
      data: {
        meetupEvents: meetup_events_as_json,
        railsEnv: Rails.env,
        referrer: referrer_get(request)
      }
    )
  end

  def event_exists?(edfa)
    meetup_dot_com_id = edfa['id']
    meetup_event = MeetupEvent.find_by(meetup_dot_com_id: meetup_dot_com_id)

    return false if !meetup_event

    to_cookie_jar_add meetup_event.id
    return true
  end
end
