# frozen_string_literal: true

module ModsDisplay
  class DateIssued < Field
    def fields
      date_fields(:dateIssued)
    end
  end
end
