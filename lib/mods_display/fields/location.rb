class ModsDisplay::Location < ModsDisplay::Field

  def label
    super || location_label(@value)
  end
  
  private
  
  def location_label(element)
    if element.attributes["type"].respond_to?(:value) && location_labels.has_key?(element.attributes["type"].value)
      location_labels[element.attributes["type"].value]
    else
      "Location"
    end
  end
  
  def location_labels
    {"repository" => "Repository"}
  end

end