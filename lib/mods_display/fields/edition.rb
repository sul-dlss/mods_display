# frozen_string_literal: true

module ModsDisplay
  class Edition < Field
    def fields
      return_fields = @stanford_mods_elements.map do |origin_info_element|
        edition_value = Stanford::Mods::Imprint.new(origin_info_element).edition_vals_str
        next unless edition_value.present?

        # remove trailing spaces (thanks MARC, for catalog card formatting!)
        edition_value.gsub!(%r{ */$}, '')

        ModsDisplay::Values.new(
          label: I18n.t('mods_display.edition'),
          values: [edition_value],
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end
  end
end
