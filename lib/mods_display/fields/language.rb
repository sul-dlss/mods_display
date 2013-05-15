class ModsDisplay::Language < ModsDisplay::Field
  def label
    return super unless super.nil?
    "Language"
  end

  def text
    return super unless super.nil?
    language_codes[@value.text.strip]
  end

  def to_html
    return nil if text.strip == ""
    super
  end

  private

  def language_codes
    SEARCHWORKS_LANGUAGES
  end

end