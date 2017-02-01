
module RSpecUtil
  class << self
    def humanize_bname(file = nil)
      file ||= caller.first.split(':').first
      File.basename(file, '.rb').sub(/\_+/, ' ').sub(/_spec/, '').humanize
    end
  end
end
