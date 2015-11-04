class ModsDisplay::Genre < ModsDisplay::Field
  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(label: displayLabel(value) || label, values: [value.text.strip.capitalize].flatten)
    end
    collapse_fields(return_fields)
  end

  private

  def displayLabel(element)
    super(element) || I18n.t('mods_display.genre')
  end
end
