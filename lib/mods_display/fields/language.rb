class ModsDisplay::Language < ModsDisplay::Field
  def fields
    return_fields = @value.map do |val|
      if val.respond_to?(:languageTerm)
        val.languageTerm.map do |term|
          if term.attributes["type"].respond_to?(:value) and term.attributes["type"].value == "code"
            ModsDisplay::Values.new(:label => displayLabel(val) || displayLabel(term) || "Language", :values => [displayForm(val) || language_codes[term.text]].flatten)
          end
        end.flatten.compact
      end
    end.flatten.compact
    collapse_fields(return_fields)
  end

  private

  def language_codes
    SEARCHWORKS_LANGUAGES
  end

end