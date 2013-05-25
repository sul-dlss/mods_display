class ModsDisplay::Identifier < ModsDisplay::Field
  
  def fields
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    @value.each_with_index do |val, index|
      current_label = (displayLabel(val) || identifier_label(val))
      if @value.length == 1
        return_values << ModsDisplay::Values.new(:label => current_label, :values => [val.text])
      elsif index == (@value.length-1)
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
  
  def identifier_label(element)
    if element.attributes["type"].respond_to?(:value)
      return identifier_labels[element.attributes["type"].value] || element.attributes["type"].value
    end
    "Identifier"
  end
  
  def identifier_labels
    {"local"                     => "Identifier",
     "isbn"                      => "ISBN",
     "issn"                      => "ISSN",
     "issn-l"                    => "ISSN",
     "doi"                       => "DOI",
     "hdl"                       => "Handle",
     "isrc"                      => "ISRC",
     "ismn"                      => "ISMN",
     "issue number"              => "Issue Number",
     "lccn"                      => "LCCN",
     "matrix number"             => "Matrix Number",
     "music publisher"           => "Music Publisher",
     "music plate"               => "Music Plate",
     "sici"                      => "SICI",
     "upc"                       => "UPC",
     "videorecording identifier" => "Videorecording Identifier",
     "stock number"              => "Stock Number"}
  end

end