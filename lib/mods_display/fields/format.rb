class ModsDisplay::Format < ModsDisplay::Field

  def fields
    return [] if (text.nil? and @value.text.strip.empty?)
    return_values = @value.map{|v| v.text }
    return_values = [text] unless text.nil?
    [ModsDisplay::Values.new(:label => label || 'Format', :values => return_values)]
  end

  def text
    return super unless super.nil?
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