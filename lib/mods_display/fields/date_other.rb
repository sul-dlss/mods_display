# frozen_string_literal: true

module ModsDisplay
  class DateOther < Field
    def fields
      date_fields(:dateOther)
    end

    private

    # this is called from the Field.select_best_date method
    # @param date [Stanford::Mods::Imprint::Date]
    def qualified_value_with_type(date)
      type = type_attribute_value(date)
      type ? "#{date.qualified_value} (#{type})" : date.qualified_value
    end

    def type_attribute_value(date)
      if date.is_a?(Stanford::Mods::Imprint::DateRange)
        date.start.value.type || date.stop.value.type
      else
        date.value.type
      end
    end
  end
end
