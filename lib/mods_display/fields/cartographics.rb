# frozen_string_literal: true

module ModsDisplay
  class Cartographics < Field
    def fields
      return nil if @stanford_mods_elements.nil?

      return_fields = []
      @stanford_mods_elements.each do |subject_element|
        next unless subject_element.respond_to?(:cartographics)

        subject_element.cartographics.each do |field|
          scale = field.scale.empty? ? 'Scale not given' : element_text(field.scale)
          projection = field.projection.empty? ? nil : element_text(field.projection)
          coordinates = field.coordinates.empty? ? nil : element_text(field.coordinates)
          post_scale = [projection, coordinates].compact.join(' ') if [projection, coordinates].compact.length.positive?

          return_fields << ModsDisplay::Values.new(
            label: displayLabel(field) || label || I18n.t('mods_display.map_data'),
            values: [[scale, post_scale].compact.join(' ; ')]
          )
        end
      end
      collapse_fields(return_fields)
    end
  end
end
