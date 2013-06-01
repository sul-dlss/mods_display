class ModsDisplay::Location < ModsDisplay::Field

  private

  def displayLabel(element)
    super(element) || location_label(element) || "Location"
  end

  def location_label(element)
    if element.attributes["type"].respond_to?(:value) && location_labels.has_key?(element.attributes["type"].value)
      location_labels[element.attributes["type"].value]
    end
  end

  def location_labels
    {"repository" => "Repository"}
  end

end