
require 'fileutils'

SUPPORT_DIR = 'spec/support'.freeze
FACTORY_GIRL_CONFIG = File.join(SUPPORT_DIR, 'factory_girl.rb').freeze
FACTORY_FILE = 'spec/factories.rb'.freeze

if ENV['REVERSE']
  raise 'TODO!!!!'
else
  gem 'factory_girl_rails', group: 'test'
  FileUtils.mkdir_p SUPPORT_DIR if !File.directory?(SUPPORT_DIR)

  create_file FACTORY_GIRL_CONFIG do
    <<~RUBY
      RSpec.configure do |config|
        config.include FactoryGirl::Syntax::Methods
      end
    RUBY
  end

  copy_file(
    File.join(File.expand_path('..', File.realpath(__FILE__)), FACTORY_FILE),
    FACTORY_FILE
  )

  system 'bundler', 'install'
end
