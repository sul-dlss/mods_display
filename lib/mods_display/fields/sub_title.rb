module ModsDisplay
  class SubTitle < Field
    def fields
      ModsDisplay::Title.new(@values[1, @values.length]).fields
    end
  end
end
