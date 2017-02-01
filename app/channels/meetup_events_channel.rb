class MeetupEventsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "meetup_events_#{uuid}"
  end
end
