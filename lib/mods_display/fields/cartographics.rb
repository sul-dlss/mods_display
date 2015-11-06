module ModsDisplay
  class Cartographics < Field
    def fields
      return nil if @values.nil?
      return_fields = []
      @values.each do |value|
        next unless value.respond_to?(:cartographics)
        value.cartographics.each do |field|
          scale = field.scale.empty? ? 'Scale not given' : field.scale.text
          projection = field.projection.empty? ? nil : field.projection.text
          coordinates = field.coordinates.empty? ? nil : field.coordinates.text
          post_scale = [projection, coordinates].compact.length > 0 ? [projection, coordinates].compact.join(' ') : nil
          return_fields << ModsDisplay::Values.new(
            label: (displayLabel(field) || label || I18n.t('mods_display.map_data')),
            values: [[scale, post_scale].compact.join(' ; ')]
          )
        end
      end
      collapse_fields(return_fields)
    end
  end
end
