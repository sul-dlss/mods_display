# frozen_string_literal: true

module ModsDisplay
  class DateCreated < Field
    def fields
      date_fields(:dateCreated)
    end
  end
end
