class ModsDisplay::Language < ModsDisplay::Field
  def fields
    return_fields = @values.map do |value|
      if value.respond_to?(:languageTerm)
        value.languageTerm.map do |term|
          if term.attributes["type"].respond_to?(:value) and term.attributes["type"].value == "code"
            ModsDisplay::Values.new(:label => displayLabel(value) || displayLabel(term) || I18n.t('mods_display.language'), :values => [displayForm(value) || language_codes[term.text]].flatten)
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