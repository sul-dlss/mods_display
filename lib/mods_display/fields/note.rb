class ModsDisplay::Note < ModsDisplay::Field
  
  def fields
    return_fields = note_fields.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || note_label(value), :values => [value.text])
    end
    collapse_fields(return_fields)
  end
  
  
  private

  def note_fields
    @values.select do |value|
      (!value.attributes["type"].respond_to?(:value) or
         (value.attributes["type"].respond_to?(:value) and
            value.attributes["type"].value.downcase != "contact"))
    end
  end

  def note_label(element)
    if element.attributes["type"].respond_to?(:value)
      return note_labels[element.attributes["type"].value] || element.attributes["type"].value.capitalize
    end
    "Note"
  end

  def note_labels
    {"statement of responsibility" => "Statement of responsibility",
     "date/sequential designation" => "Date/Sequential designation",
     "publications"                => "Publications",
     "references"                  => "References",
     "bibliography"                => "Bibliography",
     "preferred citation"          => "Preferred citation",
     "date/sequential designation" =>	"Date/Sequential designation",
     "biographical/historical"     => "Biographical/Historical",
     "creation/production credits" => "Creation/Production credits",
     "citation/reference"          => "Citation/Reference"
     }
  end

end