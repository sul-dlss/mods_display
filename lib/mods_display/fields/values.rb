# frozen_string_literal: true

module ModsDisplay
  class Values
    attr_accessor :label, :values

    def initialize(label: nil, values: [])
      @label = label
      @values = values
    end
  end
end
