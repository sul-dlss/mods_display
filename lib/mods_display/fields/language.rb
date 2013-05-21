class ModsDisplay::Language < ModsDisplay::Field
  def label
    return super unless super.nil?
    "Language"
  end

  def fields
    if @value.languageTerm.length > 0
      return_values = []
      @value.languageTerm.select do |term|
        term.attributes["type"].respond_to?(:value) && term.attributes["type"].value == "code"
      end.each do |term|
        return_values << language_codes[term.text]
      end
      [ModsDisplay::Values.new(:label => label || "Language", :values => return_values)] unless return_values.empty?
    else
      []
    end
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