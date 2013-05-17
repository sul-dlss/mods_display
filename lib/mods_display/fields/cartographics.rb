class ModsDisplay::Cartographics < ModsDisplay::Field

  def values
    return nil if @value.nil?
    return_values = []
    if @value.respond_to?(:cartographics)
      @value.cartographics.each do |field|
        scale = field.scale.empty? ? "Scale not given" : field.scale.text
        projection = field.projection.empty? ? nil : field.projection.text
        coordinates = field.coordinates.empty? ? nil : field.coordinates.text
        post_scale = [projection, coordinates].compact.length > 0 ? [projection, coordinates].compact.join(" ") : nil
        return_values << ModsDisplay::Values.new({:label => (displayLabel(field) || label || "Map Data"),
                                                  :values => [[scale, post_scale].compact.join(" ; ")]})
      end
    end
    return_values
  end

end