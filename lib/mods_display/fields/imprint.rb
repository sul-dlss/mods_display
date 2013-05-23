class ModsDisplay::Imprint < ModsDisplay::Field

  def fields
    return_values = []
    place = nil
    publisher = nil
    placePub = nil
    place = @value.place.map do |p|
      p.text unless p.text.strip.empty?
    end.compact.join(" : ").strip unless @value.place.text.strip.empty?
    publisher = @value.publisher.map do |p|
      p.text unless p.text.strip.empty?
    end.compact.join(" : ").strip unless @value.publisher.text.strip.empty?
    placePub = [place, publisher].compact.join(" : ")
    placePub = nil if placePub.strip.empty?
    parts = @value.children.select do |child|
      ["dateCreated", "dateIssued", "dateCaptured", "dateOther"].include?(child.name) and !child.attributes.has_key?("encoding")
    end.map do |child|
      child.text.strip unless child.text.strip.empty?
    end.compact.join(", ")
    parts = nil if parts.strip.empty?
    unless [placePub, parts].compact.join(", ").strip.empty?
      return_values << ModsDisplay::Values.new(:label => label || "Imprint", :values => [[placePub, parts].compact.join(", ")])
    end
    if other_pub_info.length > 0
      other_pub_info.each do |pub_info|
        return_values << ModsDisplay::Values.new(:label => label || pub_info_labels[pub_info.name.to_sym], :values => [pub_info.text.strip])
      end
    end
    imprint_display_form || return_values
  end

  def other_pub_info
    @value.children.select do |child|
      pub_info_parts.include?(child.name.to_sym)
    end
  end
  
  def imprint_display_form
    return nil if text.nil?
    [ModsDisplay::Values.new(:label => label || "Imprint", :values => [text])]
  end

  private

  def pub_info_parts
    pub_info_labels.keys
  end

  def pub_info_labels
    {:dateValid     => "Date Valid",
     :dateModified  => "Date Modified",
     :copyrightDate => "Copyright Date",
     :edition       => "Edition",
     :issuance      => "Issuance",
     :frequency     => "Frequency"
    }
  end

end