class ModsDisplay::Values
  attr_accessor :label, :values
  def initialize(values)
    values.each do |key, value|
      if [:label, :values].include?(key)
        self.send("#{key}=".to_sym, value)
      end
    end
  end

end