module ModsDisplay
  class Contents < Field
    private

    def displayLabel(element)
      super(element) || I18n.t('mods_display.table_of_contents')
    end
  end
end
