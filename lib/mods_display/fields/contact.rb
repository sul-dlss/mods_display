class ModsDisplay::Contact < ModsDisplay::Field
  def fields
    return_fields = contact_fields.map do |val|
      ModsDisplay::Values.new(:label => displayLabel(val) || "Contact", :values => [val.text])
    end
    collapse_fields(return_fields)
  end

  private
  def contact_fields
    @value.select do |val|
      val.attributes["type"].respond_to?(:value) and
        val.attributes["type"].value.downcase == "contact"
    end
  end

end