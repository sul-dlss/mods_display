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
        return_values << {:label => (displayLabel(field) || label || "Map Data"),
                          :value => [scale, post_scale].compact.join(" ; ")}
      end
    end
    return_values
  end

  def to_html
    return super if !super.nil? or values == []
    output = ""
    values.each do |cart|
      output << "<dt#{label_class}>#{cart[:label]}:</dt>"
      output << "<dd#{value_class}>"
        if @config.link
          output << link_to_value(cart[:value])
        else
          output << cart[:value]
        end
      output << "</dd>"
    end
    output
  end

end