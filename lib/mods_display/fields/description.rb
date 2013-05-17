class ModsDisplay::Description < ModsDisplay::Field  
  def values
    description_fields.map do |description|
      ModsDisplay::Values.new({:label => (label || labels[description.name.to_sym] || "Physical Description"), 
                               :values => [description.text]})
    end
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