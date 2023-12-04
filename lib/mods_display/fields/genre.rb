# frozen_string_literal: true

module ModsDisplay
  class Genre < Field
    def fields
      return_fields = @stanford_mods_elements.map do |genre_element|
        ModsDisplay::Values.new(
          label: displayLabel(genre_element) || label,
          values: [element_text(genre_element).capitalize].flatten
        )
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
