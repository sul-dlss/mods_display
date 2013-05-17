class ModsDisplay::Title < ModsDisplay::Field

  def label
    super || title_label(@value)
  end
  
  def values
    [ModsDisplay::Values.new(:label => label, :values => [text])]
  end

  def text
    return super unless super.nil?
    output = []
    title_parts.each do |part|
      output << @value.send(part).text if @value.respond_to?(part)
    end
    output.join(" ").strip
  end

  private

  def title_parts
    [:nonSort, :title, :subTitle, :partName, :partNumber]
  end

  def title_label(element)
    if (element.attributes["type"].respond_to?(:value) and
        title_labels.has_key?(element.attributes["type"].value))
      return title_labels[element.attributes["type"].value]
    end
    "Title"
  end

  def title_labels
    {"abbreviated" => "Abbreviated Title",
     "translated"  => "Translated Title",
     "alternative" => "Alternative Title",
     "uniform"     => "Uniform Title"}
  end

end