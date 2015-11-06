module ModsDisplay
  class Values
    attr_accessor :label, :values
    def initialize(values)
      values.each do |key, value|
        send("#{key}=".to_sym, value) if [:label, :values].include?(key)
      end
    end
  end
end
