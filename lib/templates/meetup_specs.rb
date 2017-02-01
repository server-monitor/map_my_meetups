
require 'fileutils'

SPEC_DIR = 'spec'.freeze

SPEC_FILES = %w[models/meetup_event_spec.rb].freeze

if ENV['REVERSE']
  SPEC_FILES.each { |file| remove_file File.join(SPEC_DIR, file) }
else
  SPEC_FILES.each do |file|
    target_file = File.join SPEC_DIR, file

    target_dir = File.dirname target_file

    FileUtils.mkdir_p target_dir if !File.directory?(target_dir)

    copy_file(
      File.join(File.expand_path('..', File.realpath(__FILE__)), target_file),
      target_file
    )
  end
end
