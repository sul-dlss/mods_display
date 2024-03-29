# frozen_string_literal: true

module ModsDisplay
  class Form < Field
    def fields
      return [] unless form_elements.present?

      [
        ModsDisplay::Values.new(
          label: I18n.t('mods_display.form'),
          values: form_elements.map { |x| element_text(x) }.uniq { |x| x.downcase.gsub(/\s/, '').gsub(/[[:punct:]]/, '') }
        )
      ]
    end

    private

    def form_elements
      @stanford_mods_elements.map(&:form).flatten
    end
  end
end
