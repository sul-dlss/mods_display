class ModsDisplay::Language < ModsDisplay::Field
  def label
    return super unless super.nil?
    "Language"
  end

  def fields
    return [] if @value.languageTerm.length < 1 or @value.languageTerm.text.strip.empty?
    return_values = []
    @value.each do |val|
      languages = []
      val.languageTerm.select do |term|
        term.attributes["type"].respond_to?(:value) && term.attributes["type"].value == "code"
      end.each do |term|
        languages << language_codes[term.text]
      end
      return_values << ModsDisplay::Values.new(:label => displayLabel(val) || "Language", :values => languages)
    end
    return_values
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