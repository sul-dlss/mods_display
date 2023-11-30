# frozen_string_literal: true

module ModsDisplay
  class CopyrightDate < Field
    def fields
      date_fields(:copyrightDate)
    end
  end
end
