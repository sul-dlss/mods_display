# frozen_string_literal: true

module ModsDisplay
  class Publisher < Field
    def fields
      return_fields = @values.map do |value|
        publisher_value = Stanford::Mods::Imprint.new(value).publisher_vals_str
        next unless publisher_value.present?

        publisher_value.gsub!(/ *,$/, '')

        ModsDisplay::Values.new(
          label: I18n.t('mods_display.publisher'),
          values: [publisher_value],
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end
  end
end
