# frozen_string_literal: true

module ModsDisplay
  class ResourceType < Field
    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(label: displayLabel(value) || label, values: [value.text.strip])
      end
      collapse_fields(return_fields)
    end

    private

    def displayLabel(element)
      super(element) || I18n.t('mods_display.type_of_resource')
    end
  end
end
