
# # Group ---------------------------------------------------------------------
# # city: Riverside
# # country: US
# # state: CA
# # lat: 33.98
# # lon: -117.33

# # group_photo:
# #   id: 437122966
# #   highres_link: http://photos2.meetupstatic.com/photos/event/5/9/b/6/highres_437122966.jpeg
# #   photo_link: http://photos4.meetupstatic.com/photos/event/5/9/b/6/600_437122966.jpeg
# #   thumb_link: http://photos4.meetupstatic.com/photos/event/5/9/b/6/thumb_437122966.jpeg

# generate :model, 'meetup_group',
#          'meetup_dot_com_id', 'name', 'link', 'timezone',
#          'photo', # => group_photo[photo_link]
#          *%w[--skip-test-framework]

# # generate :scaffold, 'meetup_group',
# #          'meetup_dot_com_id', 'name', 'link', 'timezone',
# #          'photo', # => group_photo[photo_link]
# #          *%w[--no-assets --no-test-framework --no-helper --skip]

# # Geo
# # t.string :address     <= Meetup keys
# # t.string :city        <= city
# # t.string :state       <= state
# # t.string :country     <= country
# # t.decimal :latitude   <= lat
# # t.decimal :longitude  <= lon

# inject_into_class 'app/models/meetup_group.rb', MeetupGroup do
#   <<-RUBYCODE
#   # http://api.rubyonrails.org/classes/ActiveRecord/Associations/ =>
#   # <= ClassMethods.html#method-i-has_one
#   has_one :default_address, foreign_key: 'meetup_group_id',
#                             class_name: GeoMarker
#   has_one :next_event, foreign_key: 'meetup_group_id', class_name: MeetupEvent

#   validates_presence_of :meetup_dot_com_id, :name, :link

#   def to_s
#     name
#   end
#   RUBYCODE
# end

# Event ---------------------------------------------------------------------
# id: '231280691'
# name: "[Intermediate] React & Reflux Fundamentals Workshop"
# time: 1468980000000
# utc_offset: -25200000

# id: '231280691'
# name: "[Intermediate] React & Reflux Fundamentals Workshop"
# status: upcoming
# time: 1468980000000
# updated: 1468819128000
# utc_offset: -25200000
# venue:
#   id: 24136228
#   name: 8th Light
#   lat: 34.04330062866211
#   lon: -118.25758361816406
#   address_1: 315 W 9th St. Suite 901
#   city: Los Angeles
#   country: us
#   state: CA

# Geo                   <= Meetup keys (venue)
# t.string :address     <= address_1
# t.string :city        <= city
# t.string :state       <= state
# t.string :country     <= country
# t.decimal :latitude   <= lat
# t.decimal :longitude  <= lon

MEETUP_EVENT = %w[model meetup_event].freeze
USER_MODEL_FILE = 'app/models/user.rb'.freeze
HAS_MANY_LINE_TO_BE_INSERTED = "  has_many :meetup_events\n\n".freeze

if ENV['REVERSE']
  # ... TODO WHY ...
  # destroy(*MEETUP_EVENT)
  system 'bin/rails', 'destroy', *MEETUP_EVENT
  gsub_file USER_MODEL_FILE, HAS_MANY_LINE_TO_BE_INSERTED, ''
else
  generate(
    *MEETUP_EVENT,
    'meetup_dot_com_id', 'name', 'time:decimal', 'utc_offset',
    'link',
    'user:belongs_to',
    'venue_name', # Meetup.com key: name
    *%w[--skip-test-framework]
  )

  # generate :scaffold, 'meetup_event',
  #          'meetup_dot_com_id', 'name', 'time', 'utc_offset', 'link',
  #          'user:belongs_to',
  #          'venue_name', # Meetup.com key: name
  #          *%w[--no-assets --no-test-framework --no-helper --skip]

  insert_into_file(
    'app/models/meetup_event.rb', after: 'belongs_to :user'
  ) do
    <<-RUBYCODE.chomp

  has_one :location, foreign_key: 'meetup_event_id', class_name: GeoMarker

  validates_presence_of :meetup_dot_com_id, :name, :time, :utc_offset,
                        :link,
                        :location

  def to_s
    name
  end
    RUBYCODE
  end

  inject_into_class USER_MODEL_FILE, User do
    HAS_MANY_LINE_TO_BE_INSERTED
  end
end
