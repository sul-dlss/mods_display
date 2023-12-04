# frozen_string_literal: true

module ModsDisplay
  class Description < Field
    def fields
      return_fields = description_fields.map do |element|
        ModsDisplay::Values.new(
          label: description_label(element),
          values: [element_text(element)]
        )
      end
      collapse_fields(return_fields)
    end

    def description_label(element)
      label || displayLabel(element) || labels[element.name.to_sym] || I18n.t('mods_display.physical_description')
    end

    private

    def description_fields
      @stanford_mods_elements.children.select do |child|
        labels.keys.include?(child.name.to_sym)
      end
    end

    def labels
      { digitalOrigin: I18n.t('mods_display.digital_origin'),
        note: I18n.t('mods_display.note') }
    end
  end
end
