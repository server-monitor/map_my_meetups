
MIGRATION = %w[migration AddMeetupEventToGeoMarkers].freeze
GEO_MARKER_MODEL_FILE = 'app/models/geo_marker.rb'.freeze
BELONGS_TO_LINE = "  belongs_to :meetup_event, optional: true\n\n".freeze

if ENV['REVERSE']
  # F**K you so hard!
  # destroy(*MIGRATION)
  system 'bin/rails', 'destroy', *MIGRATION
  gsub_file GEO_MARKER_MODEL_FILE, BELONGS_TO_LINE, ''
else
  generate(*MIGRATION, 'meetup_event:references')
  inject_into_class GEO_MARKER_MODEL_FILE, GeoMarker do
    BELONGS_TO_LINE
  end
end
