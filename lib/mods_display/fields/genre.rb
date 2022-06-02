# frozen_string_literal: true

module ModsDisplay
  class Genre < Field
    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(label: displayLabel(value) || label, values: [element_text(value).capitalize].flatten)
      end
      collapse_fields(return_fields)
    end

    private

    def delimiter
      '<br />'
    end

    def displayLabel(element)
      super(element) || I18n.t('mods_display.genre')
    end
  end
end
