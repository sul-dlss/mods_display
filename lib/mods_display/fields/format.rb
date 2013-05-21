class ModsDisplay::Format < ModsDisplay::Field

  def fields
    return [] if text.strip.empty?
    [ModsDisplay::Values.new(:label => label || 'Format', :values => [text])]
  end

  def text
    return super unless super.nil?
    @value.text
  end

  def to_html
    output = ""
    fields.each do |field|
      output << "<dt#{label_class}>#{field.label}:</dt>"
      output << "<dd#{value_class}>"
        field.values.map do |val|
          output << "<span class='#{self.class.format_class(val)}'>#{val}</span>"
        end.join(@config.delimiter)
      output << "</dd>"
    end
    output
  end

  private

  def format_class
    self.class.format_class(text)
  end

  def self.format_class(format)
    return format if format.nil?
    format.strip.downcase.gsub(/\/|\\|\s+/, "_")
  end

end