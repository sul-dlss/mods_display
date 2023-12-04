# frozen_string_literal: true

module ModsDisplay
  class Language < Field
    def fields
      return_fields = @stanford_mods_elements.map do |language_element|
        next unless language_element.respond_to?(:languageTerm)

        language_element.languageTerm.map do |term|
          next unless term.attributes['type'].respond_to?(:value) && term.attributes['type'].value == 'code'

          ModsDisplay::Values.new(
            label: displayLabel(language_element) || displayLabel(term) || I18n.t('mods_display.language'),
            values: [language_codes[element_text(term)]]
          )
        end.flatten.compact
      end.flatten.compact
      collapse_fields(return_fields)
    end

    private

    def language_codes
      SEARCHWORKS_LANGUAGES
    end
  end
end
