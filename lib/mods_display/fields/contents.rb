# frozen_string_literal: true

module ModsDisplay
  class Contents < Field
    def to_html(view_context = ApplicationController.renderer)
      f = fields.map do |field|
        ModsDisplay::Values.new(label: field.label, values: [field.values.join("\n\n")], field: self)
      end

      helpers = view_context.respond_to?(:simple_format) ? view_context : ApplicationController.new.view_context

      value_transformer = lambda do |value|
        text = ERB::Util.h(value.gsub('&#10;', "\n"))
        helpers.simple_format(text, {}, sanitize: false)
      end

      component = ModsDisplay::FieldComponent.with_collection(f, value_transformer: value_transformer)

      view_context.render component, layout: false
    end

    private

    def displayLabel(element)
      super(element) || I18n.t('mods_display.table_of_contents')
    end
  end
end
