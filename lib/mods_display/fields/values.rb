# frozen_string_literal: true

module ModsDisplay
  # This class has what is needed by view code in downstream applications
  class Values
    attr_accessor :label, :values, :field

    def initialize(label: nil, values: [], field: nil)
      @label = label
      @values = values
      @field = field
    end
  end
end
