# frozen_string_literal: true

module ModsDisplay
  class Contact < Field
    def fields
      return_fields = contact_elements.map do |contact_element|
        ModsDisplay::Values.new(
          label: displayLabel(contact_element) || I18n.t('mods_display.contact'),
          values: [element_text(contact_element)]
        )
      end
      collapse_fields(return_fields)
    end

    private

    def contact_elements
      @stanford_mods_elements.select do |note_element|
        note_element.attributes['type'].respond_to?(:value) &&
          note_element.attributes['type'].value.downcase == 'contact'
      end
    end
  end
end
