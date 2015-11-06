module ModsDisplay
  class Contact < Field
    def fields
      return_fields = contact_fields.map do |value|
        ModsDisplay::Values.new(label: displayLabel(value) || I18n.t('mods_display.contact'), values: [value.text])
      end
      collapse_fields(return_fields)
    end

    private

    def contact_fields
      @values.select do |value|
        value.attributes['type'].respond_to?(:value) &&
          value.attributes['type'].value.downcase == 'contact'
      end
    end
  end
end
