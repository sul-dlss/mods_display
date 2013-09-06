class ModsDisplay::ResourceType < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || label, :values => [value.text.strip.capitalize].flatten)
    end
    collapse_fields(return_fields)
  end

  private
  def displayLabel(element)
    super(element) || "Type of resource"
  end
end