
OCRUBY_GROUP_RES_BODY = JSON.parse(
  File.read(File.join(File.dirname(__FILE__), 'ocruby_group_res_body.json'))
)

def next_event_without_id
  group = JSON.parse OCRUBY_GROUP_RES_BODY.to_json
  next_event = group.fetch('next_event')
  next_event['id'] = ''
  group['next_event'] = next_event
  return group
end

OCRUBY_EVENT_RES_BODY = JSON.parse(
  File.read(File.join(File.dirname(__FILE__), 'ocruby_event_res_body.json'))
)

def event_data_from_api
  JSON.parse OCRUBY_EVENT_RES_BODY.to_json
end

def venue_data_from_api
  event_data_from_api.fetch('venue')
end

def venue_without_lat
  no_lat = venue_data_from_api
  no_lat.delete 'lat'

  return no_lat
end

def venue_without_lon
  no_lon = venue_data_from_api
  no_lon.delete 'lon'

  return no_lon
end

REMOVE_COORD_FOR = {
  lat: -> { venue_without_lat }, lon: -> { venue_without_lon }
}.freeze

def event_data_from_api_without(coord)
  without = REMOVE_COORD_FOR.fetch(coord)
  event_data_from_api.merge('venue' => without.call)
end
