class ModsDisplay::RelatedLocation < ModsDisplay::Field

  def fields
    return_values = []
    @value.each do |val|
      if val.location.length > 0 and val.titleInfo.length < 1
        return_values << ModsDisplay::Values.new(:label => displayLabel(val), :values => [val.location.text.strip])
      end
    end
    return_values
  end

  def displayLabel(element)
    super(element) || "Location"
  end

end