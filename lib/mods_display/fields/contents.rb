module ModsDisplay
  class Contents < Field
    def to_html
      f = fields.map do |field|
        ModsDisplay::Values.new(label: field.label, values: [field.values.join("\n\n")])
      end

      value_transformer = lambda do |value|
        text = ERB::Util.h(value.gsub('&#10;', "\n"))
        simple_format(text, {}, sanitize: false)
      end

      component = ModsDisplay::FieldComponent.with_collection(f, value_transformer: value_transformer)

      ApplicationController.renderer.render component
    end

    private

    def simple_format(*args)
      ApplicationController.new.view_context.simple_format(*args)
    end

    def displayLabel(element)
      super(element) || I18n.t('mods_display.table_of_contents')
    end
  end
end
