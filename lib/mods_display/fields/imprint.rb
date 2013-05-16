class ModsDisplay::Imprint < ModsDisplay::Field

  def label
    return super unless super.nil?
    if imprint?
      "Imprint"
    else
      origin_info_labels[origin_info_part]
    end
  end

  def values
    imprint_data = []
    origin_info_data = []
    @value.children.each do |child|
      if imprint_parts.include?(child.name.to_sym)
        imprint_data << child
      elsif origin_info_parts.include?(child.name.to_sym)
        origin_info_data << child
      end
    end
    {:imprint => imprint_data, :origin_info => origin_info_data}
  end

  def text
    return super unless super.nil?
    output = []
    if imprint?
      imprint_parts.each do |part|
        if @value.respond_to? part
          imprint_part = @value.send(part)
          attributes = imprint_part.attributes.first || {}
          unless ( ["dateCreated", "dateIssued"].include?(imprint_part.name.join) and
                   attributes.has_key?("encoding") )
            output << imprint_part.text
          end
        end
      end
    else
      output << @value.text.strip
    end
    output.join(" ").strip
  end

  def to_html
    return nil if text.strip == "" or (values[:imprint] == [] && values[:origi_info] == [])
    super
  end

  private

  def imprint?
    imprint_parts.any?{ |part| !@value.send(part).nil? and @value.send(part).length > 0 }
  end

  def origin_info_part
    @value.children.map do |child|
      unless child.name == "text"
        child.name
      end
    end.compact.first.to_sym
  end

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