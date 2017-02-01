
require 'capybara/poltergeist'

# Not needed right now but it's here if we need this driver in the future.
# It seems to not hurt anything.
RSpec.configure do |config|
  config.around :each, js: true, poltergeist: true do |example|
    Capybara.javascript_driver = :poltergeist

    example.run

    Capybara.use_default_driver
    Capybara.javascript_driver = :selenium
  end

  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, inspector: true, js_errors: false)
  end

  config.around :each, js: true, poltergeist_debug: true do |example|
    Capybara.javascript_driver = :poltergeist_debug

    example.run

    Capybara.use_default_driver
    Capybara.javascript_driver = :selenium
  end
end
