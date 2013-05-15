class ModsDisplay::Imprint < ModsDisplay::Field

  def label
    return super unless super.nil?
    "Imprint"
  end

  def text
    return super unless super.nil?
    output = []
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
    output.join(" ").strip
  end

  def to_html
    return nil if text.strip == ""
    super
  end

  private

  def imprint_parts
    [:place, :publisher, :dateCreated, :dateIssued]
  end

end