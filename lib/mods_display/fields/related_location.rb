class ModsDisplay::RelatedLocation < ModsDisplay::Field


  def fields
    return_values = []
    @value.each do |val|
      if val.location.length > 0
        return_values << ModsDisplay::Values.new(:label => displayLabel(val) || "Location", :values => [val.location.text.strip])
      end
    end
    return_values
  end

end