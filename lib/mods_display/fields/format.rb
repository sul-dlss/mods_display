class ModsDisplay::Format < ModsDisplay::Field

  def values
    [ModsDisplay::Values.new(:label => label || 'Format', :values => [text])]
  end

  def text
    return super unless super.nil?
    @value.text
  end

  def to_html
    output = ""
    val = values.first
    output << "<dt#{label_class}>#{val.label}:</dt>"
    output << "<dd#{value_class}>"
      output << "<span class='#{format_class}'>#{val.values.join(@config.delimiter)}</span>"
    output << "</dd>"
  end

  private

  def format_class
    return nil if text.nil?
    text.strip.downcase.gsub(/\/|\\|\s+/, "_")
  end

end