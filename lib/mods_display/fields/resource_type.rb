# frozen_string_literal: true

module ModsDisplay
  class ResourceType < Field
    def fields
      return_fields = @stanford_mods_elements.map do |type_of_resource_element|
        ModsDisplay::Values.new(
          label: displayLabel(type_of_resource_element) || label,
          values: [element_text(type_of_resource_element)]
        )
      end
      collapse_fields(return_fields)
    end

    private

    def displayLabel(type_of_resource_element)
      super || I18n.t('mods_display.type_of_resource')
    end
  end
end
