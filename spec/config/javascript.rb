
RSpec.configure do |config|
  # DEBUG... -------------------- \/\/\/\/
  config.around :each, js: true do |example|
    # Capybara::Webkit.configure { |capybara| capybara.debug = true }

    # https://groups.google.com/forum/#!topic/ruby-capybara/jpurprtIiPY
    # In short, automatic_reload prevents race conditions and
    #   you probably don't want to disable it unless you have
    #   some really, really weird use case where
    #   it doesn't make sense to reload nodes.
    # Was failing on map/hover with message:
    # Selenium::WebDriver::Error::StaleElementReferenceError:
    #    stale element reference: element is not attached to the page document
    # Capybara.automatic_reload = false
    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit

    example.run

    # Capybara::Webkit.configure { |capybara| capybara.debug = false }
    # See note above about automatic_reload...
    # Capybara.automatic_reload = true
    Capybara.use_default_driver
    Capybara.javascript_driver = :selenium
  end

  # Not working yet.
  # config.around(:each, js: true, selenium_chrome: false) do |example|
  #   Headless.ly do
  #     example.run
  #   end
  # end
end
