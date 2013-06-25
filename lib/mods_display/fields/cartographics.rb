class ModsDisplay::Cartographics < ModsDisplay::Field

  def fields
    return nil if @value.nil?
    return_values = []
    @value.each do |val|
      if val.respond_to?(:cartographics)
        val.cartographics.each do |field|
          scale = field.scale.empty? ? "Scale not given" : field.scale.text
          projection = field.projection.empty? ? nil : field.projection.text
          coordinates = field.coordinates.empty? ? nil : field.coordinates.text
          post_scale = [projection, coordinates].compact.length > 0 ? [projection, coordinates].compact.join(" ") : nil
          return_values << ModsDisplay::Values.new({:label => (displayLabel(field) || label || "Map data"),
                                                    :values => [[scale, post_scale].compact.join(" ; ")]})
        end
      end
    end
    return_values
  end

end