
require 'helpers/controllers/meetup_events'
require 'helpers/controllers/cookie_for_event_i_ds'

class MeetupEventsController < ApplicationController
  before_action :user_uuid_get, only: [:map, :leaflet, :create]

  USER_UUID_KEY = :user_uuid
  MAP_AREA_ID = 'map_canvas'.freeze

  private_constant :USER_UUID_KEY

  # Hacks...
  def delete_all
    # MeetupEvent.all.each do |meetup_event|
    #   vid = meetup_event.venue ? meetup_event.venue.id : nil
    #   Venue.find(vid).destroy if vid
    # end

    # MeetupEvent.delete_all

    delete_event_ids_cookie
    redirect_to(root_path, flash: { danger: 'DELETED ALL meetup events' })

    # Prob. not a good idea to delete this.
    # cookies.delete(USER_UUID_KEY)
  end

  def leaflet
    @meetup_event = MeetupEvent.new
    js meetupEvents: meetup_events_as_json,
       railsEnv: Rails.env,
       mapAreaId: MAP_AREA_ID
  end
  # END hacks...

  def index
    @meetup_events = MeetupEvent.all
    @meetup_event = MeetupEvent.new
  end

  def map
    @meetup_event = MeetupEvent.new
    js meetupEvents: meetup_events_as_json,
       railsEnv: Rails.env,
       mapAreaId: MAP_AREA_ID
  end

  # POST /meetup_events
  # POST /meetup_events.json
  def create
    params_for_model = Meetup::GetListOfParamsForModel.new.perform(
      meetup_event_params[:input_text]
    )

    return if params_for_model.searched_for_only_one_event? and
              errors?(params_for_model)

    params_for_model.list.each do
      |existing_event:, params:, errors_wrapper:|
      next if no_need_to_create_event?(errors_wrapper, existing_event)

      meetup_event = Meetup::CreateEvent.new.perform(params, user_id)

      next if errors? meetup_event, flash_error: false
      add_to_cookie_for_event_ids meetup_event.id
    end

    cable_broadcast
    head :ok
  end

  private

  include Helpers::Controllers::MeetupEvents
  include Helpers::Controllers::CookieForEventIDs

  def meetup_event_params
    params.permit(:input_text)
  end

  def default_redirect_fallback
    map_meetup_events_path
  end

  def user_id
    # I don't know why User::GUEST NameError in prod.
    current_user ? current_user.id : User.find_by!(email: 'guest@example.com')
    # current_user ? current_user.id : User::GUEST.id
  end

  def meetup_events_as_json
    meetup_events_as_json_helper(
      event_ids_in_cookie, current_user
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
        mapAreaId: MAP_AREA_ID
      },
      extract_referrer_from: request.referer
    )
  end

  def event_exists?(edfa)
    meetup_dot_com_id = edfa['id']
    meetup_event = MeetupEvent.find_by(meetup_dot_com_id: meetup_dot_com_id)

    return false if !meetup_event

    add_to_cookie_for_event_ids meetup_event.id
    return true
  end

  def no_need_to_create_event?(errors_wrapper, existing_event)
    return true if errors_wrapper and errors?(
      errors_wrapper, flash_error: false
    )

    if existing_event
      add_to_cookie_for_event_ids existing_event.id
      return true
    end

    return false
  end
end
