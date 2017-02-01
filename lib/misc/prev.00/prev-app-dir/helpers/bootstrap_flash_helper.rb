
# TODO: DEBUG, clean up later...
# =+= https://github.com/seyhunak/twitter-bootstrap-rails/blob/master/app/helpers/bootstrap_flash_helper.rb
module BootstrapFlashHelper
  # ALERT_TYPES = [
  #   :success, :info, :warning, :danger
  # ].freeze unless const_defined?(:ALERT_TYPES)

  def bootstrap_flash(options = {})
    flash_messages = []

    # I don't know...
    # flash.each do |raw_type, message|
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set
      #   to nothing in a locale file.
      next if message.blank?

      # DEBUG
      # type = raw_type
      # type = retrieve_type raw_type
      # next unless ALERT_TYPES.include?(type)

      tag_class = options.extract!(:class)[:class]

      # https://getbootstrap.com/components/
      # Search for "not super important"
      # <div class="alert alert-success" role="alert"> ... </div>
      # <div class="alert alert-info"    role="alert"> ... </div>
      # <div class="alert alert-warning" role="alert"> ... </div>
      # <div class="alert alert-danger"  role="alert"> ... </div>
      tag_options = {
        class: "alert fade in alert-#{type} #{tag_class}"
      }.merge(options)

      # TODO: DEBUG, research if there's another way to do this instead of
      #   raw and html_safe
      # # rubocop:disable Rails/OutputSafety
      # # rubocop:enable Rails/OutputSafety
      close_button = content_tag(
        :button, raw('&times;'),
        type: 'button', class: 'close', 'data-dismiss' => 'alert'
      )

      Array(message).each do |msg|
        text = content_tag(:div, close_button + msg, tag_options)
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  # TODO: DEBUG, delete later...
  # private

  # def retrieve_type(raw_type)
  #   # https://getbootstrap.com/components/
  #   # Search for "not super important"
  #   # <div class="alert alert-success" role="alert">
  #   #   <a href="#" class="alert-link">...</a>
  #   # </div>
  #   # <div class="alert alert-info" role="alert">
  #   #   <a href="#" class="alert-link">...</a>
  #   # </div>
  #   # <div class="alert alert-warning" role="alert">
  #   #   <a href="#" class="alert-link">...</a>
  #   # </div>
  #   # <div class="alert alert-danger" role="alert">
  #   #   <a href="#" class="alert-link">...</a>
  #   # </div>

  #   convert_from_to = {
  #     'notice' => :success,
  #     'warning' => :warning,
  #     'alert' => :danger,
  #     'error' => :danger
  #   }.freeze

  #   return convert_from_to[raw_type] if convert_from_to.key? raw_type
  #   Rails.logger.warn "# !!WARNING =+= flash type '#{raw_type}' not valid!!"
  #   return raw_type.to_sym
  #   # return :danger
  # end
end
