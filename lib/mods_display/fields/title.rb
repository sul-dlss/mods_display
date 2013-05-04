class ModsDisplay::Title
  def initialize(title)
    @title = title
  end

  def label
    if @title.attributes["displayLabel"].respond_to?(:value)
      @title.attributes["displayLabel"].value
    elsif @title.attributes["type"].respond_to?(:value) and title_labels.has_key?(@title.attributes["type"].value)
      title_labels[@title.attributes["type"].value]
    else
      "Title"
    end
  end

  def text
    output = []
    if @title.respond_to?(:displayForm)
      output << @title.displayForm.text
    else
      title_parts.each do |part|
        output << @title.send(part).text if @title.respond_to?(part)
      end
    end
    output.join(" ").strip
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