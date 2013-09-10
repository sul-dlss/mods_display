class ModsDisplay::Description < ModsDisplay::Field

  def fields
    return_fields = description_fields.map do |value|
      ModsDisplay::Values.new(:label => description_label(value), :values => [value.text])
    end
    collapse_fields(return_fields)
  end

  def description_label(element)
    label || displayLabel(element) || labels[element.name.to_sym] || "Physical description"
  end

  private

  def description_fields
    @values.children.select do |child|
      labels.keys.include?(child.name.to_sym)
    end
  end

  def labels
    {:digitalOrigin => "Digital origin",
     :note          => "Note"
     }
  end

end