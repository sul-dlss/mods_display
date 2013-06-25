class ModsDisplay::Note < ModsDisplay::Field
  
  def fields
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    note_fields.each_with_index do |val, index|
      current_label = (displayLabel(val) || note_label(val))
      if note_fields.length == 1
        return_values << ModsDisplay::Values.new(:label => current_label, :values => [val.text])
      elsif index == (note_fields.length-1)
        # need to deal w/ when we have a last element but we have separate labels in the buffer.
        if current_label != prev_label
          return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
          return_values << ModsDisplay::Values.new(:label => current_label, :values => [val.text])
        else
          buffer << val.text
          return_values << ModsDisplay::Values.new(:label => current_label, :values => buffer.flatten)
        end
      elsif prev_label and (current_label != prev_label)
        return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
        buffer = []
      end
      buffer << val.text
      prev_label = current_label
    end
    return_values
  end
  
  
  private

  def note_fields
    @value.select do |val|
      (!val.attributes["type"].respond_to?(:value) or
         (val.attributes["type"].respond_to?(:value) and
            val.attributes["type"].value.downcase != "contact"))
    end
  end

  def note_label(element)
    if element.attributes["type"].respond_to?(:value)
      return note_labels[element.attributes["type"].value] || element.attributes["type"].value
    end
    "Note"
  end

  def note_labels
    {"statement of responsibility" => "Statement of responsibility",
     "date/sequential designation" => "Date/Sequential designation",
     "references"                  => "References",
     "bibliography"                => "Bibliography",
     "preferred citation"          => "Preferred citation"}
  end

end