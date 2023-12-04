# frozen_string_literal: true

module ModsDisplay
  class Extent < Field
    def fields
      return [] unless extent_elements.present?

      [
        ModsDisplay::Values.new(
          label: I18n.t('mods_display.extent'),
          values: extent_elements.map { |x| element_text(x) }
        )
      ]
    end

    private

    def extent_elements
      @stanford_mods_elements.map(&:extent).flatten
    end
  end
end
