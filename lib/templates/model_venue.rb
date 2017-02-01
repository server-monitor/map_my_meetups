
MODEL = %w[model venue].freeze

if ENV['REVERSE']
  system 'bin/rails', 'destroy', *MODEL
else
  # id: 21898262
  # name: Eureka Bldg
  # lat: 33.69908142089844
  # lon: -117.84720611572266
  # repinned: false
  # address_1: 1621 Alton Parkway
  # city: Irvine
  # country: us
  # localized_country_name: USA
  # zip: ''
  # state: CA

  generate(
    *MODEL,
    *%w[
      meetup_event:belongs_to
      venue_id:integer
      name
      latitude:decimal{21,16}
      longitude:decimal{21,16}
      repinned:boolean
      address
      city
      state
      country
      zip:integer
    ]
  )
end
