class ModsDisplay::Description < ModsDisplay::Field  
  def values
    description_fields.map do |description|
      {:label => (label || labels[description.name.to_sym] || "Physical Description"), 
       :value => description.text}
    end
  end

  def to_html
    return super if !super.nil? or values == []
    output = ""
    values.each do |description|
      output << "<dt#{label_class}>#{description[:label]}:</dt>"
      output << "<dd#{value_class}>"
        if @config.link
          output << link_to_value(description[:value])
        else
          output << description[:value]
        end
      output << "</dd>"
    end
    output
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