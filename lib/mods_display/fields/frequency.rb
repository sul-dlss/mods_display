# frozen_string_literal: true

module ModsDisplay
  class Frequency < Field
    def fields
      return_fields = @values.map do |origin_info_element|
        frequency_value = origin_info_element.frequency&.text&.strip
        next unless frequency_value.present?

        ModsDisplay::Values.new(
          label: I18n.t('mods_display.frequency'),
          values: [frequency_value],
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end
  end
end
