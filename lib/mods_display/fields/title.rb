class ModsDisplay::Title < ModsDisplay::Field
  def label
    return super unless super.nil?
    if @value.attributes["type"].respond_to?(:value) and title_labels.has_key?(@value.attributes["type"].value)
      title_labels[@value.attributes["type"].value]
    else
      "Title"
    end
  end

  def text
    return super unless super.nil?
    output = []
    title_parts.each do |part|
      output << @value.send(part).text if @value.respond_to?(part)
    end
    output.join(" ").strip
  end

  def to_html
    return nil if text.strip == ""
    super
  end

  private

  def title_parts
    [:nonSort, :title, :subTitle, :partName, :partNumber]
  end

  def title_labels
    {"abbreviated" => "Abbreviated Title",
     "translated"  => "Translated Title",
     "alternative" => "Alternative Title",
     "uniform"     => "Uniform Title"}
  end

end