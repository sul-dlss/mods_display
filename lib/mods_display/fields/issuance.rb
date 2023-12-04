# frozen_string_literal: true

module ModsDisplay
  class Issuance < Field
    def fields
      return_fields = @stanford_mods_elements.map do |origin_info_element|
        issuance_value = origin_info_element.issuance&.text&.strip
        next unless issuance_value.present?

        ModsDisplay::Values.new(
          label: displayLabel(origin_info_element) || I18n.t('mods_display.issuance'),
          values: [issuance_value],
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end
  end
end
