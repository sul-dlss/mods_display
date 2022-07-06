# frozen_string_literal: true

module ModsDisplay
  class Values
    attr_accessor :label, :values, :field

    def initialize(label: nil, values: [], field: nil)
      @label = label
      @values = values
      @field = field
    end
  end
end
