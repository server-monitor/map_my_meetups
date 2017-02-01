
require 'net/http'
require 'pp'
require 'json'
require 'yaml'

MU_JSON_FILE = '/temp/trash/mu-json-file.json'.freeze

def main_gp(url = nil)
  if !url
    show_mu MU_JSON_FILE
    return
  end

  uri = URI(url.sub(%r{/ www [.] }x, '/api.'))
  if uri.query
    uri.query += '&' << URI.encode_www_form(
      key: ENV.fetch('API_KEY')
    )
  else
    uri.query = URI.encode_www_form(key: ENV.fetch('API_KEY'))
  end

  res = Net::HTTP.get_response(uri)

  raise res.inspect if !res.is_a? Net::HTTPSuccess

  open(MU_JSON_FILE, 'w') { |io| io.write res.body }

  show_mu MU_JSON_FILE
end

def show_mu(file)
  puts JSON.parse(File.read(file)).to_yaml
end

main_gp ARGV.first
