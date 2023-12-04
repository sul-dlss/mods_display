# frozen_string_literal: true

module ModsDisplay
  class Place < Field
    include ModsDisplay::CountryCodes

    def fields
      return_fields = @stanford_mods_elements.map do |origin_info_element|
        place_value = place_element(origin_info_element)
        next unless place_value.present?

        ModsDisplay::Values.new(
          label: I18n.t('mods_display.place'),
          values: [place_value],
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end

    private

    # not an exact duplicate of the method in Imprint, particularly trailing punctuation code
    def place_element(origin_info_element)
      return if origin_info_element.place.text.strip.empty?

      places = ModsDisplay::Imprint.new(origin_info_element).place_terms(origin_info_element).filter_map { |p| p.text unless p.text.strip.empty? }
      compact_and_remove_trailing_delimiter(places, ':').join
    end

    def compact_and_remove_trailing_delimiter(values, delimiter = ':')
      values.flatten.filter_map { |v| v.gsub(/ *#{delimiter}$/, '') if v.present? }.compact
    end
  end
end
