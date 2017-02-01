
# How the query should look...
# https://api.meetup.com/find/groups?&sign=true&photo-host=public&lon=-118.100593&text=suspense&radius=50&lat=33.939858&page=20&omit=description,organizer,group_photo,key_photo

class Events
  include MeetupEvent::Constant

  attr_reader :ids

  QUERY = {
    # text: 'The_keyword_to_search.',
    # sign: true,
    'photo-host': 'public',

    # Somewhere in Downey, CA, between LA and OC.
    lon: -118.100593,
    lat: 33.939858,
    radius: 75,

    page: (ENV['EVENTS'] || 10),
    omit: 'description,organizer,photos,group_photo,key_photo'
  }.freeze

  def initialize(search_input_input, user_id)
    @user_id = user_id
    search_input = MeetupEvent::SearchInput.new search_input_input

    if search_input.http?
      @is_multiple = false
      return
    else
      @is_multiple = true
    end

    query = query_build search_input.text

    res = MeetupEvent::APIClient.new(query).assert_success!

    events = events_get res.json

    @ids = events.collect(&:id)
  end

  def multiple?
    @is_multiple
  end

  private

  attr_reader :user_id

  def query_build(search_text)
    uri = URI.join(API, 'find/', 'groups')
    uri.query = URI.encode_www_form(sign: true)

    QUERY.merge(text: search_text).sort.each do |qkey, qparam|
      # https://stackoverflow.com/questions/16623421/ruby-how-to-add-a-param-to-an-url-that-you-dont-know-if-it-has-any-other-param
      ar = URI.decode_www_form(uri.query) << [qkey, qparam]
      uri.query = URI.encode_www_form(ar)
    end

    return uri
  end

  def events_get(groups)
    events = []
    groups.select { |group| group['next_event'] }.each do |group|
      summary = group['next_event']
      id = summary['id']

      uri = URI.join(
        group.fetch('link').sub(/http/, 'https'), 'events/', id
      )

      event = MeetupEvent.new(search_input: uri.to_s)
      event.user_id = user_id

      event.save
      next if !event.venue or event.errors.count > 1

      events.push event
    end

    return events
  end
end
