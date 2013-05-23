class ModsDisplay::Title < ModsDisplay::Field

  def label
    super || title_label(@value)
  end
  
  def fields
    [ModsDisplay::Values.new(:label => label, :values => [text])]
  end

  def text
    return super unless super.nil?
    nonSort = nil
    title = nil
    subTitle = nil
    nonSort = @value.nonSort.text.strip unless @value.nonSort.text.strip.empty?
    title = @value.title.text.strip unless @value.title.text.strip.empty?
    subTitle = @value.subTitle.text unless @value.subTitle.text.strip.empty?
    preSubTitle = [nonSort, title].compact.join(" ")
    preSubTitle = nil if preSubTitle.strip.empty?
    preParts = [preSubTitle, subTitle].compact.join(" : ")
    preParts = nil if preParts.strip.empty?
    parts = @value.children.select do |child|
      ["partName", "partNumber"].include?(child.name)
    end.map do |child|
      child.text
    end.compact.join(", ")
    parts = nil if parts.strip.empty?
    [preParts, parts].compact.join(". ")
  end

  private

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