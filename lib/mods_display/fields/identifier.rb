class ModsDisplay::Identifier < ModsDisplay::Field

  def label
    super || identifier_label(@value)
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