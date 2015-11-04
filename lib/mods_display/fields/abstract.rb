class ModsDisplay::Abstract < ModsDisplay::Field
  private

  def displayLabel(element)
    super(element) || I18n.t('mods_display.abstract')
  end
end
