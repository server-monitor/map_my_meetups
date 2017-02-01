
class MeetupEvent < ApplicationRecord
  belongs_to :user
  has_one :venue
  validates_presence_of :venue

  before_validation :assign_user

  private

  def assign_user
    self.user_id = user ? user.id : User::GUEST.id
  end
end

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- #

# require_relative './meetup_event/data_unit'
# require_relative './meetup_event/constant'

# class MeetupEvent < ApplicationRecord
#   include MeetupEvent::Constant

#   belongs_to :user
#   has_one :venue

#   # Validation doesn't make sense because these are going to be
#   #   filled up with data obtained from external sources.
#   # validates_presence_of :meetup_dot_com_id, :name, :time, :utc_offset,
#   #                       :link,
#   #                       :location

#   after_validation :event_should_not_exist
#   after_validation :retrieve_meetup_data

#   # !!method_names_should_not_be_the_same!!
#   # after_validation :event_should_not_exist
#   after_validation :check_event_should_not_exist_after_data_retrieval

#   after_validation :inject_meetup_data

#   # attr_accessor :from_map
#   # attr_accessor :search_input

#   attr_accessor :input_text

#   def to_s
#     name
#   end

#   def event_exists?
#     @existing_event
#   end

#   private

#   attr_reader :meetup_data, :input_link

#   def base_errors
#     errors[:base]
#   end

#   def input_link_set(to_this_value)
#     @input_link = to_this_value
#   end

#   def try_to_find_event(link, id_looking_string_in_event_link)
#     [
#       link,
#       link.sub(/\A https [:]/x, 'http:'),
#       link.sub(/\A https [:]/x, 'http:') .sub(%r{ /* \z}x, '/'),
#       link.sub(/\A https [:]/x, 'http:') .sub(%r{ /* \z}x, ''),
#       link.sub(/\A http  [:]/x, 'https:'),
#       link.sub(/\A http  [:]/x, 'https:').sub(%r{ /* \z}x, '/'),
#       link.sub(/\A http  [:]/x, 'https:').sub(%r{ /* \z}x, '')
#     ].each do |link_variation|
#       meetup_event = MeetupEvent.find_by(link: link_variation)

#       return meetup_event if meetup_event
#     end

#     # Because meetup.com is f**ked up.
#     meetup_event = MeetupEvent.find_by meetup_dot_com_id:
#       id_looking_string_in_event_link

#     return meetup_event if meetup_event

#     return nil
#   end

#   def setup_event_exists_state(meetup_event)
#     # Not sure if we should set errors or just rely on
#     #   @existing_event/#event_exists?
#     base_errors.push "Event #{meetup_event.name} already exists"
#     @existing_event = meetup_event
#   end

#   def event_should_not_exist
#     return if !base_errors.empty?

#     inp_link = input_link_set MeetupEvent::InputLink.new(search_input)
#     if inp_link.errors
#       base_errors.concat inp_link.errors
#       return
#     end

#     id_looking_string_in_event_link = inp_link.event?

#     return if !id_looking_string_in_event_link

#     meetup_event = try_to_find_event inp_link.uri.to_s,
#                                      id_looking_string_in_event_link

#     return if !meetup_event

#     setup_event_exists_state(meetup_event)
#     return meetup_event
#   end

#   def retrieve_meetup_data
#     return if !base_errors.empty?
#     return if event_exists?

#     meetup_data = MeetupEvent::DataUnit.new(input_link)

#     # If given a group url and no next event.
#     if meetup_data.errors
#       base_errors.concat meetup_data.errors
#       return
#     end

#     @meetup_data = meetup_data
#   end

#   def check_event_should_not_exist_after_data_retrieval
#     return if !base_errors.empty?

#     meetup_event = MeetupEvent.find_by meetup_dot_com_id:
#       meetup_data.meetup_dot_com_id

#     return meetup_event if !meetup_event

#     setup_event_exists_state(meetup_event)
#     return meetup_event
#   end

#   def inject_meetup_data
#     return if !base_errors.empty?
#     return if event_exists?

#     MeetupEvent::DataUnit::ATTRIBUTES.each do |attri|
#       public_send(attri.to_s + '=', meetup_data.public_send(attri))
#     end

#     self.name = meetup_data.name
#     self.venue_name = meetup_data.venue_name
#     raise 'user should exist (belongs_to/R5 not optional)' if !user
#     self.user_id = user_id
#     self.user_id = user ? user.id : User::GUEST.id

#     self.venue = Venue.new

#     MeetupEvent::DataUnit::VENUE_ATTRIBUTES.each do |attri|
#       venue.public_send(attri.to_s + '=', meetup_data.public_send(attri))
#     end

#     # # It breaks the thing. Investigate why later.
#     # venue.save!
#   end
# end
