
# ... edited by app generator
Geocoder.configure(
  # rubocop:disable Metrics/LineLength

  # Dynamic reconfiguration is possible, for example...
  # Geocoder.configure lookup: :mapzen,
  #                    api_key: ENV.fetch('MAPZEN_SEARCH_API_KEY')

  # Geocoding options, "global"
  timeout: 20,

  # Geocoding options, Google, default ------------------------------------------------------ #
  # !! =+= WHY THE F**K DOESN'T THIS WORK IF CONFIGURED WITH AN API KEY?! !!
  #        F**************KKKKKKK!!!!!
  # timeout: 3,                 # geocoding service timeout (secs)

  # lookup: :google,            # name of geocoding service (symbol)
  # lookup: :google,

  # language: :en,              # ISO-639 language code

  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # use_https: true,

  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)

  # api_key: nil,               # API key for geocoding service
  # api_key: 'AIzaSyAFWvgY1vDOTRIrNmGNpez013qfKxt7AsI',

  # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear

  # Geocoding options, mapzen --------------------------------------------------------------- #
  # https://mapzen.com/documentation/search/api-keys-rate-limits/
  # Mapzen Search allows you a maximum of:
  #   6 requests per second
  #   30,000 requests per day

  lookup: :mapzen,

  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)

  api_key: ENV.fetch('MAPZEN_SEARCH_API_KEY')

  # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear

  # rubocop:enable Metrics/LineLength
)
