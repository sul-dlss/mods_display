class ModsDisplay::RelatedLocation < ModsDisplay::Field

  def fields
    return_fields = @value.map do |val|
      if val.location.length > 0 and val.titleInfo.length < 1
        ModsDisplay::Values.new(:label => displayLabel(val), :values => [val.location.text.strip])
      end
    end.compact
    collapse_fields(return_fields)
  end

  def displayLabel(element)
    super(element) || "Location"
  end

end