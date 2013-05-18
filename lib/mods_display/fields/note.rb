class ModsDisplay::Note < ModsDisplay::Field

  def label
    super || note_label(@value)
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