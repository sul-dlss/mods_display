class ModsDisplay::Imprint
  def initialize(imprint)
    @imprint = imprint
  end
  
  def label
    if @imprint.attributes["displayLabel"].respond_to?(:value)
      @imprint.attributes["displayLabel"].value
    elsif @imprint.attributes["type"].respond_to?(:value) and title_labels.has_key?(@imprint.attributes["type"].value)
      title_labels[@imprint.attributes["type"].value]
    else
      "Imprint"
    end
  end
  
  def text
    output = []
    if @imprint.respond_to?(:displayForm)
      output << @imprint.displayForm.text
    else
      imprint_parts.each do |part|
        if @imprint.respond_to? part
          imprint_part = @imprint.send(part)
          attributes = imprint_part.attributes.first || {}
          unless ( ["dateCreated", "dateIssued"].include?(imprint_part.name.join) and
                   attributes.has_key?("encoding") )
            output << imprint_part.text
          end
        end
      end
    end
    output.join(" ").strip
  end
  
  private
  
  def imprint_parts
    [:place, :publisher, :dateCreated, :dateIssued]
  end
end