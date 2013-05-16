class ModsDisplay::Imprint < ModsDisplay::Field

  def values
    return_values = []
    if imprints.length > 0
      val = []
      imprints.each do |element|
        attributes = element.attributes || {}
        unless ( ["dateCreated", "dateIssued"].include?(element.name) and
                 attributes.has_key?("encoding") )
          val << element.text
        end
      end
      return_values << {:label => label || "Imprint", :value => val.map{|v| v.strip }.join(" ")}
    end
    if other_pub_info.length > 0
      other_pub_info.each do |pub_info|
        return_values << {:label => label || pub_info_labels[pub_info.name.to_sym], :value => pub_info.text.strip}
      end
    end
    imprint_display_form || return_values
  end

  def imprints
    @value.children.select do |child|
      imprint_parts.include?(child.name.to_sym)
    end
  end

  def other_pub_info
    @value.children.select do |child|
      pub_info_parts.include?(child.name.to_sym)
    end
  end
  
  def imprint_display_form
    return nil if text.nil?
    [{:label => label || "Imprint", :value => text}]
  end

  def to_html
    return nil if values == []
    output = ""
    values.each do |field|
      output << "<dt#{label_class}>#{field[:label]}:</dt>"
      output << "<dd#{value_class}>"
        if @config.link
          output << link_to_value(field[:value].strip)
        else
          output << field[:value].strip
        end
      output << "</dd>"
    end
    output
  end

  private

  def imprint_parts
    [:place, :publisher, :dateCreated, :dateIssued, :dateCaptured, :dateOther]
  end

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