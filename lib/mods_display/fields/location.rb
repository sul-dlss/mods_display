class ModsDisplay::Location < ModsDisplay::Field

  def fields
    return_fields = []
    @values.each do |location|
      location.children.each do |child|
        if location_field_keys.include? child.name.to_sym
          if child.name.to_sym == :url
            loc_label = displayLabel(location) || "Location"
            value = "<a href='#{child.text}'>#{displayLabel(child) || child.text}</a>"
          else
            loc_label = location_label(child) || displayLabel(location) || "Location"
            value = child.text
          end
          return_fields << ModsDisplay::Values.new(:label  => loc_label || displayLabel(location) || "Location",
                                                   :values => [value])
        end
      end
    end
    collapse_fields(return_fields)
  end

  private

  def location_field_keys
    [:physicalLocation, :url, :shelfLocation, :holdingSimple, :holdingExternal]
  end

  def location_label(element)
    if displayLabel(element)
      displayLabel(element)
    elsif element.attributes["type"].respond_to?(:value) && location_labels.has_key?(element.attributes["type"].value)
      location_labels[element.attributes["type"].value]
    end
  end

  def location_labels
    {"repository" => "Repository"}
  end

end