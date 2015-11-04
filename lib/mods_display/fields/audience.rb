class ModsDisplay::Audience < ModsDisplay::Field
  private

  def displayLabel(element)
    super(element) || I18n.t('mods_display.target_audience')
  end
end
