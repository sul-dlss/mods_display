# frozen_string_literal: true

module ModsDisplay
  class DateModified < Field
    def fields
      date_fields(:dateModified)
    end
  end
end
