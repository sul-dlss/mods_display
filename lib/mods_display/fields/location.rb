class ModsDisplay::Location < ModsDisplay::Field

  def label
    super || "Location"
  end

  def fields
    return_values = []
    if @value.location.length > 0
      return_values << ModsDisplay::Values.new(:label => label, :values => [@value.location.text.strip])
    end
    return_values
  end

end