
module BootstrapFormHelper
  # Will create a form input group...
  # <div class="form-group">
  #   <%= f.label :name, :class => 'control-label col-lg-small' %>
  #   <div class="col-lg-big">
  #     <%= f.text_field :name, :class => 'form-control' %>
  #   </div>
  # </div>

  # OR if a block is given...
  # <div class="form-group">
  #   <%= f.label :password, :class => 'control-label col-lg-small' %>
  #   <div class="col-lg-big">
  #     <% if @minimum_password_length %>
  #       <em>(<%= @minimum_password_length %> characters minimum)</em>
  #     <% end %>
  #     <%= f.password_field :password, :class => 'form-control',
  #                          autocomplete: 'off', placeholder: @placeholder %>
  #   </div>
  # </div>

  LABEL_WIDTH = 2
  FIELD_WIDTH = 5

  OFFSET_CLASS = "col-lg-offset-#{LABEL_WIDTH}".freeze
  FIELD_WIDTH_CLASS = "col-lg-#{FIELD_WIDTH}".freeze

  private_constant :LABEL_WIDTH, :FIELD_WIDTH

  def form_group_for(f, name, options = {}, outer_tag_options: {})
    content_tag(
      :div,
      f.public_send(
        :label, name, {
          class: "control-label col-lg-#{LABEL_WIDTH}"
        }.merge(options)
      ).concat(
        block_given? ? yield : field_for(f, :text_field, name)
      ),
      { class: 'form-group' }.merge(outer_tag_options)
    )
  end

  def no_width_restriction_field_for(
    f, field_type, name, options = {}, outer_tag_options: {}
  )
    content_tag(
      :div,
      f.public_send(
        field_type, name, { class: 'form-control' }.merge(options)
      ).html_safe,
      outer_tag_options
    )
  end

  def field_for(f, field_type, name, options = {})
    no_width_restriction_field_for(
      f, field_type, name, options,
      outer_tag_options: { class: FIELD_WIDTH_CLASS }
    )
  end

  def password_form_group_for(
    f,
    field_name = :password,
    minimum_password_length: nil, placeholder: ''
  )
    if minimum_password_length
      min_pw_msg = "(#{minimum_password_length} characters minimum)"
      if placeholder.blank?
        placeholder = min_pw_msg
      else
        placeholder += ", #{min_pw_msg}"
      end
    end

    form_group_for f, field_name do
      field_for f, :password_field, field_name,
                autocomplete: :off, placeholder: placeholder
    end
  end

  # Will produce...
  # <div class="form-group">
  #   <div class="col-lg-offset-2 col-lg-10">
  #     <%= f.submit 'Sign up', :class => 'btn btn-primary' %>
  #     <%= link_to t('.cancel', :default => t("helpers.links.cancel")),
  #           root_path, :class => 'btn btn-default' %>
  #   </div>
  # </div>
  def button_for(f, action, label)
    content_tag(
      :div,
      content_tag(
        :div,
        primary_button_for(f, action, label) +
          content_tag(:span, '  ') +
          cancel_button,
        class: "#{OFFSET_CLASS} #{FIELD_WIDTH_CLASS}"
      ),
      class: 'form-group'
    )
  end

  def primary_button_for(f, action, label)
    f.public_send(action, label, class: 'btn btn-primary')
  end

  def cancel_button(redirect_path = nil)
    redirect_path ||= root_path
    link_to(
      t('.cancel', default: t('helpers.links.cancel')),
      redirect_path,
      class: 'btn btn-default'
    )
  end

  # <div class="form-group">
  #   <div class="col-lg-offset-2 col-lg-5" style="padding-left:4px;">
  #     <hr>
  #     <% hr_shown = true %>
  #     <%= link_to "Log in", new_session_path(resource_name), class_param %>
  #   </div>
  # </div>
  def generic_button(
    title, path, btn_class_string = nil, options: {}
  )
    btn_class_string ||= 'btn btn-default btn-md'
    content_tag(
      :div,
      content_tag(
        :div,
        link_to(
          title, path, { class: btn_class_string }.merge(options)
        ),
        class: "#{OFFSET_CLASS} #{FIELD_WIDTH_CLASS} generic_button"
      ),
      class: 'form-group'
    )
  end
end
