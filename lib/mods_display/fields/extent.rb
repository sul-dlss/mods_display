module ModsDisplay
  class Extent < Field
    def fields
      return [] unless extent_fields.present?
      [
        ModsDisplay::Values.new(
          label: I18n.t('mods_display.extent'),
          values: extent_fields.map(&:text)
        )
      ]
    end

    private

    def extent_fields
      @values.map(&:extent).flatten
    end
  end
end
