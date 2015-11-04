class ModsDisplay::Description < ModsDisplay::Field
  def fields
    return_fields = description_fields.map do |value|
      ModsDisplay::Values.new(label: description_label(value), values: [value.text])
    end
    collapse_fields(return_fields)
  end

  def description_label(element)
    label || displayLabel(element) || labels[element.name.to_sym] || I18n.t('mods_display.physical_description')
  end

  private

  def description_fields
    @values.children.select do |child|
      labels.keys.include?(child.name.to_sym)
    end
  end

  def labels
    { digitalOrigin: I18n.t('mods_display.digital_origin'),
      note: I18n.t('mods_display.note')
     }
  end
end
