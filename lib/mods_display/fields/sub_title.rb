module ModsDisplay
  class SubTitle < ModsDisplay::Title
    def initialize(values)
      super(values[1..values.length])
    end
  end
end
