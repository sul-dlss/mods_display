class ModsDisplay::Imprint < ModsDisplay::Field

  def values
    imprint_data = []
    origin_info_data = []
    return_values = []
    @value.children.each do |child|
      if imprint_parts.include?(child.name.to_sym)
        imprint_data << child
      elsif origin_info_parts.include?(child.name.to_sym)
        origin_info_data << child
      end
    end
    if imprint_data.length > 0
      val = []
      imprint_data.each do |element|
        attributes = element.attributes || {}
        unless ( ["dateCreated", "dateIssued"].include?(element.name) and
                 attributes.has_key?("encoding") )
          val << element.text
        end
      end
      return_values << {:label => "Imprint", :value => val.map{|v| v.strip }.join(" ")}
    end
    if origin_info_data.length > 0
      origin_info_data.each do |origin_info|
        return_values << {:label => origin_info_labels[origin_info.name.to_sym], :value => origin_info.text.strip}
      end
    end
    return_values
  end

  def to_html
    return text if !text.nil? or values == []
    output = ""
    values.each do |field|
      output << "<dt>#{field[:label]}:</dt>"
      output << "<dd>"
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

  def origin_info_parts
    origin_info_labels.keys
  end

  def origin_info_labels
    {:dateValid     => "Date Valid",
     :dateModified  => "Date Modified",
     :copyrightDate => "Copyright Date",
     :edition       => "Edition",
     :issuance      => "Issuance",
     :frequency     => "Frequency"
    }
  end

end