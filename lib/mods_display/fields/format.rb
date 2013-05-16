class ModsDisplay::Format < ModsDisplay::Field

  def text
    return super unless super.nil?
    @value.text
  end

  def to_html
    output = ""
    output << "<dt#{label_class}>#{label || 'Format'}:</dt>"
    output << "<dd#{value_class}>"
      output << "<span class='#{format_class}'>#{text}</span>"
    output << "</dd>"
  end

  private

  def format_class
    return nil if text.nil?
    text.strip.downcase.gsub(/\/|\\|\s+/, "_")
  end

end