
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Must be put together with non-JS DB cleaner code.
  # Won't work if you extract this to another file.
  #   (a JS config file for example)
  # !! config.around ... doesn't work. Use before/after.
  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after :each, js: true do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  # Did not work when testing config.around and was placed before
  #   declaring the strategies.
  # Place after the strategy declarations even though we
  #   aren't using config.around just to be sure.
  # !! config.around ... doesn't work. Use before/after.
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
