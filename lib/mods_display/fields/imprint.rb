class ModsDisplay::Imprint < ModsDisplay::Field

  def fields
    return_values = []
    @value.each do |val|
      if imprint_display_form(val)
        return_values << imprint_display_form(val)
      else
        place = nil
        publisher = nil
        placePub = nil
        place = val.place.map do |p|
          p.text unless p.text.strip.empty?
        end.compact.join(" : ").strip unless val.place.text.strip.empty?
        publisher = val.publisher.map do |p|
          p.text unless p.text.strip.empty?
        end.compact.join(" : ").strip unless val.publisher.text.strip.empty?
        placePub = [place, publisher].compact.join(" : ")
        placePub = nil if placePub.strip.empty?
        parts = val.children.select do |child|
          ["dateCreated", "dateIssued", "dateCaptured", "dateOther"].include?(child.name) and !child.attributes.has_key?("encoding")
        end.map do |child|
          child.text.strip unless child.text.strip.empty?
        end.compact.join(", ")
        parts = nil if parts.strip.empty?
        unless [placePub, parts].compact.join(", ").strip.empty?
          return_values << ModsDisplay::Values.new(:label => displayLabel(val) || "Imprint", :values => [[placePub, parts].compact.join(", ")])
        end
        if other_pub_info(val).length > 0
          other_pub_info(val).each do |pub_info|
            return_values << ModsDisplay::Values.new(:label => displayLabel(val) || pub_info_labels[pub_info.name.to_sym], :values => [pub_info.text.strip])
          end
        end
      end
    end
    return_values
  end

  def other_pub_info(element)
    element.children.select do |child|
      pub_info_parts.include?(child.name.to_sym)
    end
  end
  
  def imprint_display_form(element)
    display_form = element.children.find do |child|
      child.name == "displayForm"
    end
    ModsDisplay::Values.new(:label => displayLabel(element) || "Imprint", :values => [display_form.text]) if display_form
  end

  private

  def pub_info_parts
    pub_info_labels.keys
  end

  def pub_info_labels
    {:dateValid     => "Date valid",
     :dateModified  => "Date modified",
     :copyrightDate => "Copyright date",
     :edition       => "Edition",
     :issuance      => "Issuance",
     :frequency     => "Frequency"
    }
  end

end