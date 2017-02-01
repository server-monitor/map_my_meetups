# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort(
  'The Rails environment is running in production mode!'
) if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# ...
# require 'shoulda-matchers'

# ... apparently, no need to require this. VCR will take care of everything.
# require 'webmock/rspec'

# =+= to make the constants visible outside of examples.
#     You have to restart Zeus if you make changes to the constants
#       if you want to see the changes take effect outside of examples.
#     Constants used inside of examples should update with the new
#       constant values just fine.
require_relative './support/constant'

# ...
Dir[Rails.root.join('spec/config/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/*.rb')]  .each { |f| require f }
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # ... because of JS => Webkit => DB cleaner
  # config.use_transactional_fixtures = true
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # https://stackoverflow.com/questions/38421853/why-is-my-rspec-not-loading-devisetestcontrollerhelpers
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Global Capybara...
  config.include Capybara::DSL
  Capybara.server = :puma
  # Capybara.app_host = 'http://127.0.0.1:47525'
  Capybara.server_port = 47_525
  Capybara.default_max_wait_time = 15

  Capybara::Webkit.configure do |webkit|
    %w[
      maps.google.com/maps-api-v3/api/js
      maps.google.com/maps/api
      csi.gstatic.com
      fonts.googleapis.com
    ].each { |url| webkit.allow_url url }
  end

  # Retry...
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.around :each, js: true do |example|
    example.run_with_retry retry: 3
  end

  # =+= to make the constants visible inside examples.
  config.before :each do
    require_relative './support/constant'
    Rails.application.load_seed
    User.send(:remove_const, :GUEST) if defined?(User::GUEST)

    # TODO: DEBUG, put guest email in constant somewhere.
    User.const_set :GUEST, User.find_by!(email: 'guest@example.com')
  end

  # =+= DEBUG...
  #     I want the constants file updates to be reloaded outside and inside
  #     of examples!
  # config.before(:all) do
  #   constants_file = File.join(
  #     File.dirname(File.realpath(__FILE__)), 'constant.rb'
  #   )

  #   if $LOADED_FEATURES.find { |path| path == constants_file }
  #     load constants_file
  #   else
  #     require constants_file
  #   end
  # end

  # ... to view a page in the middle of a test:
  #     1. Uncomment these 2 webkit lines
  #     2. Pass js: true to example
  #     3. Put...
  #        p current_url: current_url
  #        binding.pry
  #        # ...before the spot where you want the test to stop.
  # Capybara::Webkit.configure(&:block_unknown_urls)
  # Capybara.javascript_driver = :webkit
end

# # ...
# Shoulda::Matchers.configure do |config|
#   config.integrate do |with|
#     with.test_framework :rspec
#     with.library :rails
#   end
# end
