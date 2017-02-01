
require 'controllers/events'

class MeetupEventsController < ApplicationController
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
    # cookies[:fu] = %w[fuck you javascript].to_json
    # pp fu: cookies[:fu]
    # # cookies[MEETUP_EVENT_IDS_KEY] = '[192]'

    # pp action: :map,
    #    MEETUP_EVENT_IDS_KEY => cookies[MEETUP_EVENT_IDS_KEY],
    #    USER_UUID_KEY => cookies[USER_UUID_KEY]

    @meetup_event = MeetupEvent.new
    js meetupEvents: meetup_events_as_json, railsEnv: Rails.env
  end

  # POST /meetup_events
  # POST /meetup_events.json
  def create
    # TODO: DEBUG, if input is just http...(www.)meetup.com what?
    input_text_param = meetup_event_params[:input_text]
    if input_text_param.blank?
      error_redirect 'Must enter meetup group, event or keyword to search'
      return
    end

    user_id = current_user ? current_user.id : User::GUEST.id

    # BEGIN NEW
    input_text = Meetup::InputText.new input_text_param
    return if errors? input_text

    uri = input_text.validated_uri?
    if uri
      next_event_uri = \
        if input_text.event?
          uri
        else
          summary = Meetup::API::GetNextEventSummary.new.perform(uri.to_s)
          return if errors? summary
          summary.uri
        end

      event_data = Meetup::API::GetEventData.new.perform(next_event_uri.to_s)
      return if errors? event_data

      param_for_venue_model = Meetup::ConvertAPIDataToParamFor::
                                      VenueModel.new.perform(event_data.venue)
      return if errors? param_for_venue_model

      venue = Venue.new(param_for_venue_model.data)
      venue.save
      return if errors? venue

      param_for_meetup_event_model = \
        Meetup::ConvertAPIDataToParamFor::MeetupEventModel.new.perform(
          event_data.without_venue
        )

      return if errors? param_for_meetup_event_model

      meetup_event = MeetupEvent.new(
        param_for_meetup_event_model.data.merge(
          venue: venue, user_id: user_id
        )
      )
      meetup_event.save
      return if errors? meetup_event

      respond_to_helper
      # meetup_event.data = raw_data

      # if meetup_event.save
      #   respond_to_helper
      #   # respond_to do |format|
      #   #   # format.js { render :no_page_reload }
      #   #   format.js { redirect_back fallback_location: map_meetup_events_path }
      #   # end
      # else
      #   respond_to_helper flash: { danger: meetup_event.error }
      #   # respond_to do |format|
      #   #   format.js { render :error, errors: meetup_event.error }
      #   # end
      # end
    else
      EventsSearchJob.perform_later(input_text)
      head :ok # ?
      return
    end

    # END NEW

    # user_id = nil
    # guest_user_uuid = nil
    # if current_user
    #   user_id = current_user.id
    # else
    #   user_id = User::GUEST.id
    #   guest_user_uuid = 'guest_user_' << SecureRandom.uuid
    #   cookies[:guest_user_uuid] = guest_user_uuid
    # end

    # Event?
    #   Exists? YES: get event, redirect to map, finish
    #   NO: ...
    # Group

    # redis = Redis.new
    # redis.set 'guest_user_uuid', guest_user_uuid
    # pp keys: redis.keys

    # # HACK...
    # events = Events.new(meetup_event_params[:search_input], user_id)

    # if events.multiple?
    #   events.ids.each { |id| ids_in_cookie_jar add: id }
    #   redirect_back fallback_location: map_meetup_events_path
    #   return
    # end

    # ApiRequestJob.perform_later(meetup_event_params[:search_input])
    # return

    # guest_user_uuid = 'guest_user_' << SecureRandom.uuid
    # cookies[:guest_user_uuid] = guest_user_uuid
    # pp  WHYFUCK: cookies[MEETUP_EVENT_IDS_KEY], IN: :create, user: cookies[USER_UUID_KEY]
    # binding.pry

    # # set(wait_until: 5.seconds).
    # ApiRequestJob.perform_later(
    #   meetup_event_params[:search_input],
    #   user_id, user_uuid_get,
    #   *ids_in_cookie_jar
    # )

    # # Wait? DEBUG, TODO...
    # head :ok
    # # redirect_back(fallback_location: root_path)

    # @meetup_event = MeetupEvent.new(meetup_event_params)
    # @meetup_event.user_id = user_id
    # # @meetup_event.user_id = current_user ? current_user.id : User::GUEST.id

    # @meetup_event.validate

    # existing_event = @meetup_event.event_exists?
    # if existing_event
    #   redirect_params = { fallback_location: map_meetup_events_path }

    #   if ids_in_cookie_jar.include? existing_event.id
    #     redirect_params[:flash] = {
    #       warning: %{
    #         Event "#{existing_event.name}"
    #         (ID "#{existing_event.meetup_dot_com_id}") already exists
    #       }
    #     }
    #   else
    #     ids_in_cookie_jar add: existing_event.id
    #   end

    #   redirect_back redirect_params
    #   return
    # end

    # respond_to do |format|
    #   # rubocop:disable Metrics/LineLength
    #   if @meetup_event.save
    #     ids_in_cookie_jar add: @meetup_event.id if !current_user

    #     # channel = 'meetup_events'
    #     # bdata = { meetupEvents: meetup_events_as_json, railsEnv: Rails.env }

    #     # broadcast_to(channel, bdata)

    #     # format.html { redirect_to @meetup_event, notice: 'Meetup event was successfully created.' }
    #     format.json { render :show, status: :created, location: @meetup_event }

    #     # I guess this will do in lieu of ActionCable.
    #     format.js { redirect_back fallback_location: map_meetup_events_path }
    #     # format.js { redirect_to map_meetup_events_path }
    #     # format.js { head :ok }
    #   else
    #     # format.html { render :index }
    #     errors = @meetup_event.errors
    #     err_msgs = errors[:base] ? errors[:base].join("\n") : errors
    #     format.js do
    #       redirect_back(fallback_location: root_path, flash: { danger: err_msgs })
    #     end

    #     format.json { render json: @meetup_event.errors, status: :unprocessable_entity }
    #   end
    #   # rubocop:enable Metrics/LineLength
    # end
  end

  private

  def meetup_event_params
    params.permit(:input_text)
    # params.require(:meetup_event).permit(:input_text)
  end

  def respond_to_helper(fallback_location: nil, options: {})
    fallback_location ||= map_meetup_events_path
    respond_to do |format|
      format.js do
        redirect_back options.merge(fallback_location: fallback_location)
      end
      # format.js { render :error, errors: meetup_event.error }
    end
  end

  def error_redirect(msg)
    respond_to_helper options: { flash: { danger: msg } }
  end

  def errors?(object)
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

    error_redirect error_messages
    return true
  end

  # def broadcast_to(channel, this_data)
  #   ActionCable.server.broadcast(channel, this_data)
  # end

  # def error_redirect(format, msg:)
  #   format.js do
  #     redirect_back(fallback_location: root_path, flash: { danger: msg })
  #   end

  #   format.json { render json: msg, status: :unprocessable_entity }
  # end

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
end
