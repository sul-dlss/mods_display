class ModsDisplay::Description < ModsDisplay::Field

  def fields
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    description_fields.each_with_index do |val, index|
      current_label = description_label(val)
      if description_fields.length == 1
        return_values << ModsDisplay::Values.new(:label => current_label, :values => [val.text])
      elsif index == (description_fields.length-1)
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

  def description_label(element)
    label || displayLabel(element) || labels[element.name.to_sym] || "Physical Description"
  end

  private

  def description_fields
    @value.children.select do |child|
      labels.keys.include?(child.name.to_sym)
    end
  end

  def labels
    {:form          => "Form",
     :extent        => "Extent",
     :digitalOrigin => "Digital Origin",
     :note          => "Note"
     }
  end

end