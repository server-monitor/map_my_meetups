
require 'net/http'
require 'pp'
require 'json'
require 'yaml'

MU_JSON_FILE = '/temp/trash/mu-group.json'.freeze
MU_EVENT_JSON_FILE = '/temp/trash/mu-event.json'.freeze

def main_gp(url = nil)
  if !url
    show_mu MU_JSON_FILE
    return
  end

  uri = URI(url.sub(%r{/ www [.] }x, '/api.'))
  uri.query = URI.encode_www_form(key: '5813725d313f494b40317336e6534a')

  res = Net::HTTP.get_response(uri)

  raise res.inspect if !res.is_a? Net::HTTPSuccess

  open(MU_JSON_FILE, 'w') { |io| io.write res.body }

  show_mu MU_JSON_FILE, uri
end

def show_mu(mu_group_file, uri = nil)
  raise "Event mu_group_file '#{mu_group_file}' does not exist" \
    if !File.exist?(mu_group_file)

  next_ev = next_event(mu_group_file, uri)

  puts next_ev.to_yaml

  puts "\n# For copy and paste in expected spec..."
  transform = {
    time: nil,
    utc_offset: nil
  }.reduce({}) do |memo, (key, val)|
    json_key = val || key.to_s
    memo.merge(key.to_s => format_integer(next_ev.fetch(json_key)))
  end.merge(
    {
      meetup_dot_com_id: 'id',
      link: nil
    }.reduce({}) do |memo, (key, val)|
      json_key = val || key.to_s
      memo.merge(key.to_s => format_string(next_ev.fetch(json_key)))
    end
  )

  merge_venue = transform.merge(
    { latitude: 'lat', longitude: 'lon' }.reduce({}) do |memo, (key, val)|
      json_key = val || key.to_s
      memo.merge(
        key.to_s => format_number(next_ev.fetch('venue').fetch(json_key))
      )
    end.merge(
      {
        venue_name: 'name',
        address: 'address_1',
        city: nil,
        state: nil,
        country: nil
      }.reduce({}) do |memo, (key, val)|
        json_key = val || key.to_s
        memo.merge(
          key.to_s => format_string(next_ev.fetch('venue').fetch(json_key))
        )
      end
    )
  )

  puts(
    {
      indent: {
        indent: {
          indent: merge_venue
        }
      }
    }.to_yaml.delete('"').sub(/, \s* \z/mx, '')
  )

  # transform = {
  #   meetup_dot_com_id: 'id',
  #   time: nil,
  #   utc_offset: nil,
  #   link: nil
  # }.reduce({}) do |memo, (key, val)|
  #   json_key = val || key.to_s
  #   memo.merge(key.to_s => "'#{next_ev.fetch(json_key)}',")
  # end

  # puts(
  #   {
  #     indent: {
  #       indent: {
  #         indent: transform.merge(
  #           {
  #             venue_name: 'name', latitude: 'lat', longitude: 'lon',
  #             address: 'address_1',
  #             city: nil,
  #             state: nil,
  #             country: nil
  #           }.reduce({}) do |memo, (key, val)|
  #             json_key = val || key.to_s
  #             memo.merge(
  #               key.to_s => "'#{next_ev.fetch('venue').fetch(json_key)}',"
  #             )
  #           end
  #         )
  #       }
  #     }
  #   }.to_yaml.delete('"').sub(/, \s* \z/mx, '')
  # )

  puts
end

def next_event(mu_group_file, uri = nil)
  json = \
    if uri
      event_id = retrieve_event_id(JSON.parse(File.read(mu_group_file)))
      mu_group_path = uri.path
      mu_group_path += '/' if mu_group_path[-1] != '/'
      events_uri = URI.join(uri, mu_group_path, 'events/', event_id)
      events_uri.query = uri.query

      res = Net::HTTP.get_response(events_uri)

      raise res.inspect if !res.is_a? Net::HTTPSuccess

      json_string = res.body

      open(MU_EVENT_JSON_FILE, 'w') { |io| io.write json_string }

      JSON.parse json_string
    else
      raise "Meetup event JSON file '#{MU_EVENT_JSON_FILE}' must exist" \
        if !File.exist?(MU_EVENT_JSON_FILE)

      JSON.parse(File.read(MU_EVENT_JSON_FILE))
    end

  return json.reject { |key, _| key == 'description' }
end

def retrieve_event_id(json)
  hash_key_path = %w[next_event id]
  event_id = json.dig(*hash_key_path) or
    raise "hash key path invalid '#{hash_key_path}'"
  return event_id
end

def format_integer(integer)
  negative = integer < 0 ? true : false
  grouped = integer.to_s.gsub(/\D/, '').reverse.gsub(/.{3}/, '\0_').reverse
  grouped = '-' << grouped if negative
  "#{grouped},"
end

def format_number(number)
  "#{number},"
end

def format_string(string)
  "'#{string}',"
end

main_gp ARGV.first
