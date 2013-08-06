class ModsDisplay::Identifier < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || identifier_label(value), :values => [value.text])
    end
    collapse_fields(return_fields)
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
     "issue number"              => "Issue number",
     "lccn"                      => "LCCN",
     "matrix number"             => "Matrix number",
     "music publisher"           => "Music publisher",
     "music plate"               => "Music plate",
     "sici"                      => "SICI",
     "upc"                       => "UPC",
     "videorecording identifier" => "Videorecording identifier",
     "stock number"              => "Stock number"}
  end

end