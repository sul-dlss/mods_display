class ModsDisplay::RelatedLocation < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      if value.location.length > 0 and value.titleInfo.length < 1
        ModsDisplay::Values.new(:label => displayLabel(value), :values => [value.location.text.strip])
      end
    end.compact
    collapse_fields(return_fields)
  end

  def displayLabel(element)
    super(element) || "Location"
  end

end