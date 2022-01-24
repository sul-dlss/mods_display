# frozen_string_literal: true

module ModsDisplay
  class SubTitle < ModsDisplay::Title
    def initialize(values)
      super(values[1..values.length])
    end
  end
end
