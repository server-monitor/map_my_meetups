
MEETUP_EVENTS_CONTROLLER = %w[controller meetup_events].freeze

if ENV['REVERSE']
  system 'bin/rails', 'destroy', *MEETUP_EVENTS_CONTROLLER
else
  generate(
    *MEETUP_EVENTS_CONTROLLER,
    *%w[map create parking],
    *%w[--skip-test-framework --skip-helper --skip-assets]
  )
end
