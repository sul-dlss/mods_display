class ModsDisplay::Note < ModsDisplay::Field
  
  def fields
    return_values = []
    @value.each do |val|
      return_values << ModsDisplay::Values.new(:label => displayLabel(val) || note_label(val), :values => [val.text])
    end
    return_values
  end
  
  
  private
  
  def note_label(element)
    if element.attributes["type"].respond_to?(:value)
      return note_labels[element.attributes["type"].value] || element.attributes["type"].value
    end
    "Note"
  end
  
  def note_labels
    {"statement of responsibility" => "Statement of Responsibility",
     "date/sequential designation" => "Date/Sequential Designation",
     "references"                  => "References",
     "bibliography"                => "Bibliography",
     "preferred citation"          => "Preferred citation"}
  end

end