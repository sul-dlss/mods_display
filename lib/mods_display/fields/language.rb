class ModsDisplay::Language < ModsDisplay::Field
  def label
    return super unless super.nil?
    "Language"
  end

  def values
    [ModsDisplay::Values.new(:label => label || "Language", :values => [text])]
  end

  def text
    return super unless super.nil?
    language_codes[@value.text.strip] || @value.text.strip
  end

  private

  def language_codes
    SEARCHWORKS_LANGUAGES
  end

end