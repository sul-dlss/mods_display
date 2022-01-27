# frozen_string_literal: true

module ModsDisplay
  class Form < Field
    def fields
      return [] unless form_fields.present?

      [
        ModsDisplay::Values.new(
          label: I18n.t('mods_display.form'),
          values: form_fields.map(&:text).uniq { |x| x.downcase.gsub(/\s/, '').gsub(/[[:punct:]]/, '') }
        )
      ]
    end

    private

    def form_fields
      @values.map(&:form).flatten
    end
  end
end
