# frozen_string_literal: true

module ModsDisplay
  class Abstract < Field
    private

    def displayLabel(element)
      super || I18n.t('mods_display.abstract')
    end
  end
end
