# frozen_string_literal: true

module ModsDisplay
  class Note < Field
    def fields
      return_fields = note_fields.map do |note_element|
        ModsDisplay::Values.new(
          label: displayLabel(note_element) || note_label(note_element),
          values: [element_text(note_element)],
          field: self
        )
      end
      collapse_fields(return_fields)
    end

    private

    def delimiter
      '<br />'.html_safe
    end

    def note_fields
      @stanford_mods_elements.select do |note_element|
        !note_element.attributes['type'].respond_to?(:value) ||
          (note_element.attributes['type'].respond_to?(:value) &&
             note_element.attributes['type'].value.downcase != 'contact')
      end
    end

    def note_label(element)
      return note_labels[element.attributes['type'].value] || "#{element.attributes['type'].value.capitalize}:" if element.attributes['type'].respond_to?(:value)

      I18n.t('mods_display.note')
    end

    def note_labels
      { 'statement of responsibility' => I18n.t('mods_display.statement_of_responsibility'),
        'date/sequential designation' => I18n.t('mods_display.date_sequential_designation'),
        'publications' => I18n.t('mods_display.publications'),
        'references' => I18n.t('mods_display.references'),
        'bibliography' => I18n.t('mods_display.bibliography'),
        'preferred citation' => I18n.t('mods_display.preferred_citation'),
        'biographical/historical' => I18n.t('mods_display.biographical_historical'),
        'creation/production credits' => I18n.t('mods_display.creation_production_credits'),
        'citation/reference' => I18n.t('mods_display.citation_reference') }
    end
  end
end
