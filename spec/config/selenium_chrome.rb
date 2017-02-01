# https://stackoverflow.com/questions/7263564/unable-to-obtain-stable-firefox-connection-in-60-seconds-127-0-0-17055

RSpec.configure do |config|
  # Moved to rails_helper.rb
  # Use Puma to make Websockets and others work.
  # Capybara.server = :puma
  # # Capybara.app_host = 'http://127.0.0.1:47525'
  # Capybara.server_port = 47_525

  Capybara.register_driver :selenium_chrome do |app|
    desired_capabilities = {}

    # Since Headless is not working yet, for now,
    #   in order for the browser to not obstruct your monitor,
    #   set browser size to small.
    # https://stackoverflow.com/questions/13802363/how-to-set-browser-window-size-in-rspec-selenium
    desired_capabilities = {
      'chromeOptions' => {
        'args' => %w{
          window-size=80,420
        }
      }
    } if ENV['SHOW'].blank?

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      desired_capabilities: desired_capabilities
    )
  end

  config.around :each, js: true, selenium_chrome: true do |example|
    Capybara.current_driver = :selenium_chrome
    Capybara.javascript_driver = :selenium_chrome

    example.run

    Capybara.use_default_driver
    Capybara.javascript_driver = :selenium
  end

  # # Not working yet.
  # config.around(:each, js: true, selenium_chrome: true) do |example|
  #   Headless.ly do
  #     example.run
  #   end
  # end
end
