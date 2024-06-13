# frozen_string_literal: true

module ModsDisplay
  class Audience < Field
    private

    def displayLabel(element)
      super || I18n.t('mods_display.target_audience')
    end
  end
end
