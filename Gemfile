# ... edited by app generator

source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# ...
# gem 'coffee-rails', '~> 4.2'

gem 'jquery-rails'
gem 'turbolinks', '~> 5'

gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# .... ---- .... ---- .... ---- .... ---- .... ---- .... ---- .... ----

gem 'devise'
gem 'geoip', require: false
gem 'pry-rails'
gem 'geocoder'
gem 'bootstrap-sass'
gem 'figaro'
gem 'paloma'

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'headless'
  gem 'simplecov', require: false
  # ...
  gem 'chromedriver-helper'

  # ...
  gem 'webmock'
  gem 'vcr'

  gem 'launchy'

  # ...
  gem 'factory_girl_rails'

  # # ... Not needed?!
  # gem 'puffing-billy'
  gem 'poltergeist'

  # ...
  gem 'rspec-retry'

  # ... needs rspec-rails to be in dev and test groups
  gem 'shoulda-callback-matchers'
end

gem 'rack-mini-profiler', require: false
gem 'flamegraph'
gem 'stackprof'
gem 'memory_profiler'
gem 'colorize'

gem 'resque'
gem 'resque-web', require: 'resque_web'

# ...
gem 'immutable-struct'

# Guard and friends
group :development do
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
end

group :development, :test do
  gem 'zeus'
end
