class ModsDisplay::Title < ModsDisplay::Field

  def fields
    return_values = []
    @value.each do |val|
      if displayForm(val)
        return_values << ModsDisplay::Values.new(:label => displayLabel(val) || title_label(val), :values => [displayForm(val)])
      else
        nonSort = nil
        title = nil
        subTitle = nil
        nonSort = val.nonSort.text.strip unless val.nonSort.text.strip.empty?
        title = val.title.text.strip unless val.title.text.strip.empty?
        subTitle = val.subTitle.text unless val.subTitle.text.strip.empty?
        preSubTitle = [nonSort, title].compact.join(" ")
        preSubTitle = nil if preSubTitle.strip.empty?
        preParts = [preSubTitle, subTitle].compact.join(" : ")
        preParts = nil if preParts.strip.empty?
        parts = val.children.select do |child|
          ["partName", "partNumber"].include?(child.name)
        end.map do |child|
          child.text
        end.compact.join(parts_delimiter(val))
        parts = nil if parts.strip.empty?
        return_values << ModsDisplay::Values.new(:label => displayLabel(val) || title_label(val), :values => [[preParts, parts].compact.join(". ")])
      end
    end
    return_values
  end

  private

  def parts_delimiter(element)
    children = element.children.to_a
    # index will retun nil which is not comparable so we call 100 if the element isn't present (thus meaning it's at the end of the list)
    if (children.index{ |c| c.name == "partNumber" } || 100) < (children.index{|c| c.name == "partName"} || 100)
      return ", "
    end
    ". "
  end

  def title_label(element)
    if (element.attributes["type"].respond_to?(:value) and
        title_labels.has_key?(element.attributes["type"].value))
      return title_labels[element.attributes["type"].value]
    end
    "Title"
  end

  def title_labels
    {"abbreviated" => "Abbreviated title",
     "translated"  => "Translated title",
     "alternative" => "Alternative title",
     "uniform"     => "Uniform title"}
  end

end