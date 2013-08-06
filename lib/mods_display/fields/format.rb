class ModsDisplay::Format < ModsDisplay::Field

  def fields
    return [] if @values.text.strip.empty?
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || "Format", :values => [displayForm(value) || value.text])
    end
    collapse_fields(return_fields)
  end

  def to_html
    return nil if @config.ignore?
    output = ""
    fields.each do |field|
      output << "<dt#{label_class} title='#{field.label}'>#{field.label}:</dt>"
      output << "<dd#{value_class}>"
        field.values.map do |val|
          output << "<span class='#{self.class.format_class(val)}'>#{val}</span>"
        end.join(@config.delimiter)
      output << "</dd>"
    end
    output
  end

  private

  def self.format_class(format)
    return format if format.nil?
    format.strip.downcase.gsub(/\/|\\|\s+/, "_")
  end

end